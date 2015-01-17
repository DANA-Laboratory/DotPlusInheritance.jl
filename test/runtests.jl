using DotPlusInheritance 
using Base.Test
# reload("../v0.4/DotPlusInheritance/test/runtests.jl")
type BaseModel
  a
  b
end
type ChildModel
  _base_1::BaseModel
  a
  c
end
type FooModel
  _base_1::ChildModel
  mv::ChildModel
end
type MultiInher
  _base_1::BaseModel
  _base_2::ChildModel
  mv::FooModel
end
# a member
@test dotplus(ChildModel,:c) == :c
# base member
@test dotplus(ChildModel,:b) == :(_base_1.b)
# a member
@test dotplus(FooModel,:mv) == :mv
# memberVariable's base member
@test dotplus(FooModel,:(mv.b)) == :(mv._base_1.b)
# memberVariable's member
@test dotplus(FooModel,:(mv.c)) == :(mv.c)
# over write
@test dotplus(ChildModel,:a) == :a

m1=BaseModel(1,2)
@test dotplus(:m1,:a) == :(m1.a)
@test (:m1.+:a) == m1.a
@test dotplus(:m1,:b) == :(m1.b)
@test (:m1.+:b) == m1.b
m2=ChildModel(m1,3,4)
@test dotplus(:m2,:a) == :(m2.a)
@test (:m2.+:a) == m2.a
@test dotplus(:m2,:b) == :(m2._base_1.b)
@test (:m2.+:b) == m2._base_1.b
@test dotplus(:m2,:c) == :(m2.c)
@test (:m2.+:c) == m2.c 
m3=FooModel(m2,m2)
@test dotplus(:m3,:(mv.a)) == :(m3.mv.a)
@test :m3.+:(mv.a) == m3.mv.a
@test dotplus(:m3,:(mv.c)) == :(m3.mv.c)
@test :m3.+:(mv.c) == m3.mv.c
@test dotplus(:m3,:(mv.b)) == :(m3.mv._base_1.b)
@test :m3.+:(mv.b) == m3.mv._base_1.b
@test dotplus(:m3,:b) == :(m3._base_1._base_1.b)
@test :m3.+:b == m3._base_1._base_1.b
# _base_2 over writes _base_1
m4=MultiInher(m1,m2,m3)
@test dotplus(:m4,:a) == :(m4._base_2.a)
@test :m4.+:a == m4._base_2.a
@test dotplus(:m4,:b) == :(m4._base_2._base_1.b)
@test (:m4.+:b) == m4._base_2._base_1.b 
@test dotplus(:m4,:c) == :(m4._base_2.c)
@test (:m4.+:c) == m4._base_2.c
@test dotplus(:m4,:(mv.mv.c)) == :(m4.mv.mv.c)
@test (:m4.+:(mv.mv.c)) == m4.mv.mv.c
