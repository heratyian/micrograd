require_relative "../lib/micrograd"

a = Micrograd::Value.new(-4.0, label: 'a')
b = Micrograd::Value.new(2.0, label: 'b')
c = Micrograd::Value.new(10.0, label: 'c')
e = a * b; e.label = 'e'
d = e + c; d.label = 'd'
f = Micrograd::Value.new(-2.0, label: 'f')
g = d * f; g.label = 'g';
h = Micrograd::Value.new(5.0, label: 'h')
i = g - h; i.label = 'i'

i.backward!
i.draw_dot

# c += c + 1
# c += 1 + c + (-a)
# d += d * 2 + (b + a).relu()
# d += 3 * d + (b - a).relu()
# e = c - d
# f = e**2
# g = f / 2.0
# g += 10.0 / f
# puts "#{g.data}" # prints 24.7041, the outcome of this forward pass
# g.backward()
# puts "#{a.gradient}" # prints 138.8338, i.e. the numerical value of dg/da
# puts "#{b.gradient}" # prints 645.5773, i.e. the numerical value of dg/db

# l = d * f; l.label = 'L';

# l.backward!
# l.draw_dot
