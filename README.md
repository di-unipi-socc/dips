<picture>
    <source media="(prefers-color-scheme: dark)" srcset="img/logo-dark.png"><img width=450 alt="dips-logo" src="img/logo.png"/>
</picture>

### _Declarative Provisioning of Virtual Network Function Chains in Intent-based Networks_.

**DIPS** methodology is described and assessed in:

> [Jacopo Massa](https://pages.di.unipi.it/massa), [Stefano Forti](https://pages.di.unipi.it/forti), [Federica Paganelli](https://pages.di.unipi.it/paganelli), [Patrizio Dazzi](https://pages.di.unipi.it/dazzi), [Antonio Brogi](https://pages.di.unipi.it/brogi)<br>
> [**Declarative Provisioning of Virtual Network Function Chains in Intent-based Networks.**](https://doi.org/10.1109/NetSoft57336.2023.10175449), <br>	
> IEEE 9th International Conference on Network Softwarization (NetSoft), 2023.

*DIPS* is a Prolog tool that exploits a declarative methodology for modelling and processing VNF-based service provisioning intents. 
DIPS enables users (i.e. application providers) to specify their desired VNF chain requirements in a high-level language that captures their intent, such as the type of service to be provided, possible location constraints (e.g. at the _edge_), Quality of Service (QoS) (e.g. _latency_ and _bandwidth_), but also non-functional requirements (e.g. _privacy_ and _logging_). DIPS leverages Prolog inference to translate intents into provisioning specifications.


 ## How To &nbsp;<picture><source media="(prefers-color-scheme: dark)" srcset="https://cdn-icons-png.flaticon.com/512/2666/2666505.png"><img width="20" height="20" alt="files" src="https://cdn-icons-png.flaticon.com/512/2666/2666469.png">
</picture>

1. Download or clone this repository. Make sure you have [SWI-Prolog](https://www.swi-prolog.org/download/stable) installed.

2. In the project folder, run the following command on the command line, to access the SWI-Prolog console and load the main file:
    ```console 
    swipl dips.pl
    ```

3. Execute the main query:
    ```prolog
    :- dips(IntentId, Output).
    ```

    where `IntentId` is the unique ID of the intent to be processed, and `Output` is the output of the reasoner.
    Be sure to set the correct NumberOfUsers that the intent will serve in the `intent/4`fact, located in the `data/services/<service_name>.pl` file.

    `Output` is a list of tuples, where each tuple is of the form `(L, Placement, UP)`:
    - `L` is the number of unsatisfied properties (i.e. the number of properties that do not meet expectations) 
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



