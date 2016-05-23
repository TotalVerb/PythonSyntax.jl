pymodule"""
module1

class A:
    def __init__(self, x, y):
        self.x = x
        self.y = y

v = A(10, 20)
"""

pymodule"""
module2

class MyComplex:
    def __init__(self, re, im):
        self.re = re
        self.im = im

    def __add__(self, other: MyComplex):
        return MyComplex(self.re + other.re,
                         self.im + other.im)

    def __sub__(self, other: MyComplex):
        return MyComplex(self.re - other.re,
                         self.im - other.im)

    def __mul__(self, other: MyComplex):
        return MyComplex(self.re * other.re - self.im * other.im,
                         self.re * other.im + self.im * other.re)

    def __eq__(self, other: MyComplex):
        return self.re == other.re and self.im == other.im

a = MyComplex(7, 8)
b = MyComplex(-2, 3)
"""

@testset "Classes" begin

@test module1.v.x == 10
@test module1.v.y == 20

@test module2.a + module2.b == module2.MyComplex(5, 11)
@test module2.a - module2.b == module2.MyComplex(9, 5)
@test module2.a * module2.b == module2.MyComplex(-38, 5)

end  # testset
