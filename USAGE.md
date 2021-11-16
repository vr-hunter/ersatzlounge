# What does this app do?
This app allows you to check the current production status of cars, that were ordered from VW 
Germany and are registered with your VW ID using a "Commission Number".

## What is a VW ID?
A VW ID is the user ID that you use to log into ["My Volkswagen"](https://www.volkswagen.de/myvolkswagen).
Create one if you haven't done so already. Once you've created your VW ID, register your vehicle on
the same website using your commission number.

If you have several vehicles registered to your VW ID, make sure they have unique names. Otherwise, 
the app will not be able to distinguish between them properly.


## What is a commission number?
A commission number is a number that identifies an ordered vehicle before a VIN (vehicle identification
number) is assigned to it. 

## ...and where do I get it?
Ask your dealer for it after ordering a VW vehicle. 

# What information does the app show?
Once you've logged in, the app shows a dataset for each vehicle registered to your VW ID. Each vehicle entry
has at least two fields: 
- VIN: The "vehicle identification number"
- Commission ID: The commission ID (unique version of the commission number)

If the vehicle has a commission ID, three more fields should appear:
- Order status: The current production status. This is one of:
    - *ORDERED*: The order was placed, but the vehicle is not yet scheduled for production. 
    - *SCHEDULED*: The vehicle is scheduled for production.
    - *IN_PRODUCTION*: The vehicle is currently being produced.
    - *PRODUCED*: Production is finished but not yet shipped.
    - *DEALER_ARRIVED*: Vehicle is on it's way to the dealer.
    - *DEALER_STORED*: Vehicle has arrived at the dealer.
    - *CUSTOMER_DELIVERED*: Vehicle has been delivered to the customer.
- Delivery date type: Defines the precision of the delivery date. the Can be one of Quarter, Month oder Day. 
- Delivery date value: The scheduled delivery date. How reliable this value is depends on the order status and the "Delivery date type". 

## What does "null" mean?
So you're seeing "null" in one or more of the fields? This means that VW doesn't currently provide that information.

A VIN, for example, is usually only created days before the production starts. Your delivery date type and
value may be "null" because there is currently no information on when the car is going to be built.




