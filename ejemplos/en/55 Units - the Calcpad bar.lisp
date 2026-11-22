# Units: the bar says in which unit you want to SEE the result

#: You write the quantity with its unit attached and, after the bar, the unit in which you want to read it: **`3m|cm`**. The conversion and the dimension check are done by the engine, not by the sheet.
L = 3m|cm
e = 2.5in|mm
t = 1.5h|min

## Where each unit comes from

#: The bases (kg, m, s, A, K, mol, cd, rad) are worth 1 and the others are their physical FORMULA: the newton is m·kg/s², the pascal is N/m², the joule is N·m. The prefixes are functions: kilo, centi, milli. So there is no table of factors to maintain, and a compound unit builds itself:
F = 2.5MN|kgf
P = 30kW*2h|kJ

## The footing case (sheets 48 and 54)

#: The ultimate load of Braja Das example 3.8 spread over its effective area, read in the three units one works with: the book's, the soil study's and the concrete's.
q = 606kN/1.193m^2|kPa
q_t = 606kN/1.193m^2|tonf/m2
q_c = 606kN/1.193m^2|kgf/cm2
#: And the subgrade modulus used by the finite element model, converted from the site system to SI:
k_s = 2000tonf/m^3|kN/m^3

## What it does NOT let you do

#: If the dimensions do not match, it warns instead of giving a number that looks fine. Adding metres to seconds means nothing, and asking for a length in seconds does not either:
mal = 3m+2s|m
mal_2 = 3m|s

## In one line

#: A quantity is stored as a number and eight exponents (mass, length, time, current, temperature, substance, luminosity, angle). Multiplying adds exponents, dividing subtracts them, and adding requires them to be the same: both the conversion and the warning come from that.
