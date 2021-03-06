# DotPlusInheritance
[![Build Status](https://travis-ci.org/DANA-Laboratory/DotPlusInheritance.jl.svg?branch=master)](https://travis-ci.org/DANA-Laboratory/DotPlusInheritance.jl)
### What is this?
  Not really a solution for inheritance, but a simple way for evaluating expressions when u think having inheritance relationships between involved types could simplifies expressions and help modeler do better.
### How, when, and for whom it helps? 
  Julia dose not supports inheritance like standard object oriented langs e.g.(c++ or java).
  But inheritance really is a good feature when creating mathematical models of real world objects.
  I solve this problem for myself (when modeling process equipments) by writing a this simple module that simulates Type Inheritance.
  This trick creates a direct way to address all variables of member variables with special prefix before their names (at this time prefix is *`__base__`*) by using their Symbols. 
  Although it's not really inheritance, now i can define a _Special Pump_ type that have all variables of a _Basic_ one. 
  and evaluate expressions like:
  `:(mypump.anSpecialPump_variable*mypump.aBasicPump_variable)` 
  in place of  
  `:(mypump.anSpecialPump_mv*mypump.basicPumpModel.aBasicPump_mv)` 
  this really simplifies creating large models of various equipment each with many equations.
### Defines:
```julia
dotplus(t::DataType,ex::Union(Expr,Symbol)) 
dotplus(var::Symbol,ex::Union(Expr,Symbol)) 
(.+)(var::Symbol,ex::Union(Expr,Symbol))
```
### Usage:
1- install, download package files and copy DotPlusInheritance.jl folder to your `Pkg.dir()`

2- `use DotPlusInheritance`

3- in child type use base as a member with **\_base\_** prefix 
```julia
type BaseModel
  a
  b
end
type ChildModel
  _base_1::BaseModel
  a
  c
end
```
4- generate a dot expression to address a **base member** from **child type**
```julia
@test dotplus(ChildModel,:b) == :(_base_1.b)
```
5- use `dotplus(::Symbol,::Union(Expr,Symbol))` to address a **base member** from a **drived variable**

6- or use `.+` to get value
```julia
m1=BaseModel(1,2)
@test dotplus(:m1,:a) == :(m1.a)
@test :m1.+:a == m1.a
m2=ChildModel(m1,3,4)
#Over write
@test dotplus(:m2,:a) == :(m2.a)
@test :m2.+:a == m2.a
#Base member 
@test dotplus(:m2,:b) == :(m2._base_1.b)
@test :m2.+:b == m2._base_1.b
@test dotplus(:m2,:c) == :(m2.c)
@test :m2.+:c == m2.c
```
