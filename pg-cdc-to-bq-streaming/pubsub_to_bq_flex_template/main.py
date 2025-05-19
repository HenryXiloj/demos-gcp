import json
import argparse
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ParseCDCMessage(beam.DoFn):
    def __init__(self, failed_tag):
        self.failed_tag = failed_tag

    def process(self, message):
        try:
            decoded = message.decode("utf-8")
            logger.info("📥 Raw Pub/Sub message: %s", decoded)
            record = json.loads(decoded)

            for change in record.get("change", []):
                if change.get("kind") == "insert":
                    row = dict(zip(change["columnnames"], change["columnvalues"]))
                    logger.info("✅ Parsed row: %s", row)
                    yield row
                else:
                    logger.debug("⚠️ Skipping non-insert event: %s", change.get("kind"))
        except Exception as e:
            logger.error("❌ Failed to parse message: %s", str(e))
            yield beam.pvalue.TaggedOutput(self.failed_tag, {
                "error_message": str(e),
                "raw_data": message.decode("utf-8")
            })

def run():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_topic', required=True)
    parser.add_argument('--output_table', required=True)
    parser.add_argument('--failed_table', required=False)
    args, beam_args = parser.parse_known_args()

    pipeline_options = PipelineOptions(beam_args, save_main_session=True, streaming=True)
    failed_tag = 'failed'

    with beam.Pipeline(options=pipeline_options) as p:
        parsed = (
            p
            | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(topic=args.input_topic)
            | 'Parse CDC Message' >> beam.ParDo(ParseCDCMessage(failed_tag)).with_outputs(failed_tag, main='main')
        )

        parsed.main | 'Write to BigQuery' >> beam.io.WriteToBigQuery(
            args.output_table,
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER
        )

        if args.failed_table:
            parsed.failed | 'Write Failed Records' >> beam.io.WriteToBigQuery(
                args.failed_table,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
            )

if __name__ == '__main__':
    run()