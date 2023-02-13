<picture>
    <source media="(prefers-color-scheme: dark)" srcset="img/logo-dark.png"><img width=400 alt="dips-logo" src="img/logo.png"/>
</picture>

# _Declarative Intent Provisioning System_

## Files &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/2822/2822755.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/2822/2822584.png"/>
</picture>

```bash
├── dips.pl
└── src
    ├── checks.pl
    ├── data.pl
    └── utils.pl
```

 - [`dips.pl`](dips.pl) contains the main logic of the reasoner.

 - [`src/data.pl`](src/data.pl) contains all the _facts_ an intent is made of (e.g. _property expectations_, _conditions_), and also the description of each VNF to be placed.

 - [`src/checks.pl`](src/checks.pl) contains the predicates that check the _conditions_ of the intent, both at the assembly (associated to _changing probperties_) and placement phases (_non-changing properties_).

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
    :- dips(IntentId, NumberOfUsers, Output).
    ```

    where `IntentId` is the unique ID of the intent to be processed, `NumberOfUsers` is the number of users that will be served by the VNF chain, and `Output` is the output of the reasoner.


