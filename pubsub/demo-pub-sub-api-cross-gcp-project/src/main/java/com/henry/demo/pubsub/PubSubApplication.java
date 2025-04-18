package com.henry.demo.pubsub;

import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import com.google.cloud.spring.pubsub.integration.AckMode;
import com.google.cloud.spring.pubsub.integration.inbound.PubSubInboundChannelAdapter;
import com.google.cloud.spring.pubsub.integration.outbound.PubSubMessageHandler;
import com.google.cloud.spring.pubsub.support.BasicAcknowledgeablePubsubMessage;
import com.google.cloud.spring.pubsub.support.GcpPubSubHeaders;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.MessagingGateway;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import com.google.cloud.spring.pubsub.core.PubSubConfiguration;

import com.google.api.gax.core.CredentialsProvider;
import com.google.cloud.spring.core.GcpProjectIdProvider;
import com.google.cloud.spring.pubsub.support.DefaultPublisherFactory;
import com.google.cloud.spring.pubsub.support.DefaultSubscriberFactory;

@Slf4j
@Configuration
public class PubSubApplication {

    private final String topicName = "my_topic_test";
    private final String subscriptionName = "my_topic_test-sub";
    private final String projectId = "my_project_id";

    /**
     * Creates a PubSub configuration bean.
     */
    @Bean
    public PubSubConfiguration pubSubConfiguration() {
        return new PubSubConfiguration();
    }

    /**
     * Creates a customized PubSubTemplate with an internal project ID provider.
     */
    @Bean
    public PubSubTemplate customPubSubTemplate(CredentialsProvider credentialsProvider) {

        GcpProjectIdProvider localProjectIdProvider = () -> projectId;

        // Manually create and initialize PubSubConfiguration with the project ID
        PubSubConfiguration pubSubConfiguration = new PubSubConfiguration();
        pubSubConfiguration.initialize(projectId);

        DefaultPublisherFactory publisherFactory = new DefaultPublisherFactory(localProjectIdProvider);
        publisherFactory.setCredentialsProvider(credentialsProvider);

        DefaultSubscriberFactory subscriberFactory =
                new DefaultSubscriberFactory(localProjectIdProvider, pubSubConfiguration);
        subscriberFactory.setCredentialsProvider(credentialsProvider);

        return new PubSubTemplate(publisherFactory, subscriberFactory);
    }

    /**
     * Creates an inbound channel adapter for receiving messages from Pub/Sub.
     */
    @Bean
    public PubSubInboundChannelAdapter messageChannelAdapter(
            @Qualifier("pubsubInputChannel") MessageChannel inputChannel,
            PubSubTemplate pubSubTemplate) {
        PubSubInboundChannelAdapter adapter =
                new PubSubInboundChannelAdapter(pubSubTemplate, subscriptionName);
        adapter.setOutputChannel(inputChannel);
        adapter.setAckMode(AckMode.MANUAL);

        return adapter;
    }

    /**
     * Creates the message channel for Pub/Sub input.
     */
    @Bean
    public MessageChannel pubsubInputChannel() {
        return new DirectChannel();
    }

    @Bean
    @ServiceActivator(inputChannel = "pubsubInputChannel")
    public MessageHandler messageReceiver() {
        return message -> {
            log.info("Message arrived! Payload: {}", new String((byte[]) message.getPayload()));
            BasicAcknowledgeablePubsubMessage originalMessage =
                    message.getHeaders().get(GcpPubSubHeaders.ORIGINAL_MESSAGE, BasicAcknowledgeablePubsubMessage.class);
            originalMessage.ack();
        };
    }

    @Bean
    @ServiceActivator(inputChannel = "pubsubOutputChannel")
    public MessageHandler messageSender(PubSubTemplate pubsubTemplate) {
        return new PubSubMessageHandler(pubsubTemplate, topicName);
    }

    @MessagingGateway(defaultRequestChannel = "pubsubOutputChannel")
    public interface PubsubOutboundGateway {

        void sendToPubsub(String text);
    }
}
