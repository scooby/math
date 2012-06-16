"""
Experimenting with a composable hash for a rope class.

What I need is for different orders of concatenations of different
flats to not affect the hash value.

Requirements:  h((a . b) . c) == h(a . (b . c))
Preferred:     h(a . b) != h(b . a)
Options:  define h(expr) = f(g(expr), len(expr)), so that the length
          further hashes the result


"""

import random as rn

def test(f, g, h):
    a = "What I need is for different "
    b = "orders of concatenations of different flats "
    c = "to not affect the hash value."
    ab = a + b
    bc = b + c
    abc = a + b + c
    f_a = f(a)
    f_b = f(b)
    f_c = f(c)
    f_ab = f(ab)
    f_bc = f(bc)
    f_abc = f(abc)
    g_fa_fbc = g(f_a, f_bc)
    g_fab_fc = g(f_ab, f_c)
    h_fabc = h(f_abc, len(abc))
    h_a_bc = h(g_fa_fbc, len(abc))
    h_ab_c = h(g_fab_fc, len(abc))
    return """f(a)             = %x
f(b)             = %x
f(c)             = %x
f(ab)            = %x
f(bc)            = %x
f(abc)           = %x
g(f(a), f(bc))   = %x
g(f(ab), f(c))   = %x
h(f(abc))        = %x
h(g(f(a), f(bc)) = %x
h(g(f(ab), f(c)) = %x""" % (f_a, f_b, f_c, f_ab, f_bc, f_abc,
                            g_fa_fbc, g_fab_fc, h_fabc, h_a_bc,
                            h_ab_c)

bound = (1 << 32) - 5
mask = (1 << 32) - 1

def flat(string):
    """ Numbers are from 1 to bound. """
    x = 1
    for char in string:
        x = ((x * (2 + ord(char))) - 1) % bound + 1
    return x

def mult(hash_a, hash_b):
    """ Combine two hashes as though the flats had
    been concatenated. """
    return (hash_a * hash_b - 1) % bound + 1

def blorg(num, base=1627):
    """ Takes a value and gets something very large to xor
    against. """
    return pow(base, num, bound)

def final(num, length, rand=rn.getrandbits(32)):
    """ rand ensures that for any given session, hashes change. """
    return (num ^ blorg(length + 4) ^ rand) & mask

print(test(flat, mult, final))
