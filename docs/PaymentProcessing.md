Eidolon uses CardFlight for credit card tokenization. CardFlight is like ARAnalytics, but for payment processors. We do this for flexibility in terms of hardware and software. 

So. There are a few things you should know. 

CardFlight's concept of "Test" accounts doesn't really translate well for our purposes. So when testing on staging, we _do actually_ tokenize cards with our actual production Stripe account. Then we give the tokens to our staging server, which is using proper staging Stripe credentials, so the verification fails (that's OK). Just something to be aware of.

We have a manual credit card entry screen that uses the Stripe SDK directly (in case CardFlight goes down). 

