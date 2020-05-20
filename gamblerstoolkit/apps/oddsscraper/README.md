# OddsScraper
Modular GenServer for fault tolerent webscraping of odds data from various popular sites and bookmakers.
The Scraper is set to scraper MLB odds and can be configured to any sport.

![Image of Greyjoy](https://i.ytimg.com/vi/nEXZQmA8Yj4/maxresdefault.jpg|width=300)

## Installation
* Install Ubuntu, Erlang and Elixir on your computer.
* Install Phantom.js or Chrome headless Browser
* Install xvfb

## Start PhantomJs in Bash (you may use Chrome if you like) 
Run Phantom.js in a bash shell screen instance

> sudo screen -S phantomJS
> <screen> xvfb-run phantomjs --wd
 
If you use Chrome Headless Browser or selenium then you have to configure it in config/config.ex
Change the line: 

> config: hound, driver: chromedriver ( or selenium)

## Start the Server
> iex -S mix

# Functions

### MlbOdds.Oracle
The Oracle is a Genserver which acts as a resgistry for dynamically supervised scrapers

### Functions

&nbsp;&nbsp;**Function:** *odds_axlotl(agent)*  
&nbsp;&nbsp;**Purpose:**  creates a new scraping agent  
&nbsp;&nbsp;**Arity:** (1)  
&nbsp;&nbsp;&nbsp;&nbsp;Agent:  A scraping agent in the MlbOdds NameSpace,  located in the scrapers folder  
&nbsp;&nbsp;&nbsp;&nbsp;> *eg:  MlbOdds.SBRAgent*  

&nbsp;&nbsp;**Function:** *get_state()*  
&nbsp;&nbsp;**Purpose:**  gets the state which is a registry of supervised scrapers.  
&nbsp;&nbsp;**Arity:** (0)  


&nbsp;&nbsp;**Function:** *swap_date(date)*  
&nbsp;&nbsp;**Purpose:** swaps out the date in all agents and gets the odds for that day  
&nbsp;&nbsp;**Arity:** (1)  
&nbsp;&nbsp;&nbsp;&nbsp;**Date <sigil>:**  A scraping agent in the MlbOdds NameSpace,  located in the scrapers folder  
&nbsp;&nbsp;&nbsp;&nbsp;> *eg:  ~D[2019-03-28]  
 
### Usage

** Getting Odds **
Simply get the state of the scraper to return the state, updated ever 5 seconds.
> MlbOdds.SBRAgent.get_state

