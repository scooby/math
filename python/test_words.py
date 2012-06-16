prime_bound = (1 << 32) - 5
pow_bound = 1 << 32
mask = pow_bound - 1

def flat(string):
    """ Numbers are from 1 to bound. """
    x = 1
    for char in string:
        x = ((x * (2 + ord(char))) - 1) % prime_bound + 1
    return x

def blorg(num, base=1627):
    """ Takes a value and gets something very large to xor
    against. """
    return pow(base, num, pow_bound)

def final(num, length, rand=rn.getrandbits(32)):
    """ rand ensures that for any given session, hashes change. """
    return (num ^ blorg(length + 4) ^ rand) & mask

class word(str):
    def __hash__(self):
        return final(flat(self), len(self))

words = set()
strs = set()

word_file = "/home/ben/tree"

with open(word_file, "r") as fh:
    words.update(word(line) for line in fh)

with open(word_file, "r") as fh:
    strs.update(fh)

def compare(name, avast):
    print("%s: %d elems, %s bytes" % (name, len(avast), avast.__sizeof__()))

compare("words", words)
compare("strs", strs)
