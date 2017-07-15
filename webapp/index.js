let path = require('path');
let Pusher = require('pusher');
let express = require('express');
let bodyParser = require('body-parser');
let app = express();
let pusher = new Pusher(require('./config.js'));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.post('/update_text', function(req, res){
  var payload = {text: req.body.text, deviceId: req.body.from}
  pusher.trigger('collabo', 'text_update', payload)
  res.json({success: 200})
});

app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

module.exports = app;

app.listen(4000, function(){
  console.log('App listening on port 4000!');
});
