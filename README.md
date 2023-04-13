<picture>
    <source media="(prefers-color-scheme: dark)" srcset="img/logo-dark.png"><img width=450 alt="dips-logo" src="img/logo.png"/>
</picture>

**DIPS** is Prolog tool that exploits a declarative methodology for modelling and processing VNF-based service provisioning intents. 

DIPS enables users (i.e. application providers) to sepcify their desired VNF chain requirements in a high-level language that captures teir intent, such as the type of service to be provided, possible location constraints (e.g. at the _edge_), Quality of Service (QoS) (e.g. _latency_ and _bandwidth_), but also non-functional requirements (e.g. _privacy_ and _logging_). DIPS leverages Prolog inference to translate intents into provisioning specifications.

## Files &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/2822/2822755.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/2822/2822584.png"/>
</picture>

```bash
.
├── dips.pl
└── src
    ├── checks.pl
    ├── data.pl
    └── utils.pl
```

 - [`dips.pl`](dips.pl) contains the main logic of the reasoner.

 - [`src/data.pl`](src/data.pl) contains all the _property expectations_ an intent is made of and also the description of each VNF to be placed.

 - [`src/properties.pl`](src/properties.pl) contains the predicates that check the intent _properties_, both at the assembly (associated to _changing properties_) and placement phases (_non-changing properties_).

 - [`src/utils.pl`](src/utils.pl) contains a set of useful predicates to _(i)_ assemble the VNF chain, and _(ii)_ compute QoS metrics during the placement phase.


 ## How To &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/2666/2666505.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/2666/2666469.png">
</picture>

1. Download or clone this repository. Make sure you have [SWI-Prolog](https://www.swi-prolog.org/download/stable) installed.

2. In the project folder, run the following command on terminal, to access the SWI-Prolog console and load the main file:
    ```console 
    swipl dips.pl
    ```

3. Execute the main query:
    ```prolog
    :- dips(StakeHolder, IntentId, NumberOfUsers, Output).
    ```

    where `StakeHolder` is the unique ID of the stakeholder who requested the intent, `IntentId` is the unique ID of the intent to be processed, `NumberOfUsers` is the number of users that will be served by the VNF chain, and `Output` is the output of the reasoner.

    `Output` is a list of tuples, where each tuple is of the form `(L, Placement, UP)`:
    - `L` is the number of unsatisfied properties (i.e. the number of properties that do not meet the expectations) 
    - `Placement` is the placement of the VNF chain, and
    - `UP` is the list of unsatisfied properties.

    `UP` is also a list of tuples, where each tuple is of the form `(Property, Desired, Actual)`: 
    - `Property` that is not satisfied, 
    - `Desired` is the desired value for that property, and
    - `Actual` is the actual value obtained by the respective placement.

## Output Example &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/3488/3488340.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/3488/3488804.png"></picture>

```prolog
Output = [(0, [on(encVF, s, gateway), on(edgeGamingVF, l, edge1), on(encVF, s, edge1), on(logVF, s, cloud1), on(cloudGamingVF, m, cloud1)], []), 
 	  (0, [on(encVF, s, gateway), on(edgeGamingVF, l, edge1), on(encVF, s, edge1), on(logVF, s, cloud1), on(cloudGamingVF, m, cloud2)], []), 
	  …
	  (1, [on(encVF, s, gateway), on(edgeGamingVF, l, edge2), on(encVF, s, gateway), on(logVF, s, cloud2), on(cloudGamingVF, m, cloud1)], 
          [(bandwidth, desired(100), actual(30))]), 
	  (1, [on(encVF, s, gateway), on(edgeGamingVF, l, edge2), on(encVF, s, gateway), on(logVF, s, cloud2), on(cloudGamingVF, m, cloud2)], 
          [(bandwidth, desired(100), actual(30))])].
```

## Contributors &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/3369/3369157.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/3369/3369137.png"></picture>

 - [Jacopo Massa](https://pages.di.unipi.it/massa) (_corresponding author_)
 - [Stefano Forti](https://pages.di.unipi.it/forti)
 - [Federica Paganelli](https://pages.di.unipi.it/paganelli)
 - [Patrizio Dazzi](https://pages.di.unipi.it/dazzi)
 - [Antonio Brogi](https://pages.di.unipi.it/brogi)



