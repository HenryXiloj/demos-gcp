function transform(line) {
    var fields = line.split(',');

    var obj = {};
    obj.customer_id = parseInt(fields[0], 10);
    obj.first_name = fields[1];
    obj.last_name = fields[2];
    obj.email = fields[3];

    return JSON.stringify(obj);
}
