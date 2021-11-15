# Ersatzlounge

A flutter app to query to show the production status of ordered vehicles registered to a VW ID. 
For more information see [USAGE.md](USAGE.md)

## General

When a new vehicle is ordered from VW, one can register the so-called commission number to ones
VW ID. Until recently, there was a web-portal (the so-called "VW lounge") that showed the current
production status and an estimated delivery date. However, this portal has been recently deactivated.

Since the underlying API is still operational, there are workarounds to display the data on a PC but
no working solutions for mobile devices.

This app for Android queries the relevant VW APIs and displays the data.

## Building

See automated CI/CD workflows in .github/workflows

## Usage

- Register a VW ID  and add a car by commission number [here](https://www.volkswagen.de/de/besitzer-und-nutzer/myvolkswagen.html) (If not already done)
- Start the app and use the VW ID username and password to log in
- Status of all registered vehicles should appear in the overview
