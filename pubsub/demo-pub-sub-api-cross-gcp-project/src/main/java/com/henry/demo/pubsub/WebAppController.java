package com.henry.demo.pubsub;

import  com.henry.demo.pubsub.PubSubApplication.PubsubOutboundGateway;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.view.RedirectView;


@Slf4j
@RestController
public class WebAppController {

    private final  PubsubOutboundGateway messagingGateway;

    public WebAppController(PubsubOutboundGateway messagingGateway) {
        this.messagingGateway = messagingGateway;
    }

    @PostMapping("/publishMessage")
    public RedirectView publishMessage(@RequestParam("message") String message) {
        messagingGateway.sendToPubsub(message);
        return new RedirectView("/");
    }

}
