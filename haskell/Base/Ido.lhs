\documentclass{article}

%include polycode.fmt
\usepackage{amsmath}

\begin{document}

\section{Name}

Ido base $(-1 + i)$ conversion 

\subsection{Description}

ido (short for $i$ dash one, as meaning $i - 1$) is a
library to convert a pair of integers to a unique whole number using a
complex base conversion.

\subsection{Conjecture}

I propose that any value $a + bi$ where $a$ and $b$ are integers can be
represented as a binary string $c$ of $n$ bits such that:

\[
  a + bi = c_0 (-1+i)^0 + c_1 (-1+i)^1 + \ldots{} + c_n (-1+i)^n
\]

$c$ itself is also an integer in base 2 form.
Further, although $a$ and $b$ are integers, $c$ is always a whole number.

\subsection{Module}

This module doesn't declare a data type. At the moment, it works with any
Bits type.

\begin{code}
module Base.Ido (ido2abi, abi2ido)
       where

import Data.Bits
\end{code}

\subsection{Bit folds}

The basic idea is to fold over a number as though it's a list of bits.

This implements a right fold over bits, and is equal to:

\[ (v_n \lozenge \cdots (v_2 \lozenge (v_1 \lozenge (v_0 \lozenge z))) \cdots ) \]

Where $\lozenge$ is some binary operator. If $v$ is $-1$, the fold
will not terminate.

\begin{code}

bitFoldr :: Bits e => (e -> a -> a) -> a -> e -> a
bitFoldr f z v = go v
  where go 0 = z
        go v = (v .&. 1) `f` go (v `shiftR` 1)

\end{code}

\subsection{ido2abi}

Given a whole integer $c$, return $a + bi$.

Operates as your standard base 2 conversion, only instead of each
place representing a power of 2 it represents a power of $(-1 + i)$.

At the least significant bit, $(-1 + i)^0 = (1 + 0i)$.

To find the next highest power of $(-1 + i)$, the formula is a
standard complex multiplication:

\begin{align}
  (a + bi) (-1 + i) &= -a + ai - bi - b \\
                    &= (-a - b) + (a - b)i
\end{align}

\begin{code}

ido2abi :: Bits a => a -> (a, a)
ido2abi i = fst $ bitFoldr f ((0, 0), (1, 0)) i
  where f e ((sa, sb), (a, b)) = 
          ((sa + a * e, sb + b * e), ((-a) - b, a - b))
                    
\end{code}
          
\subsection{abi2ido}

Given the integers $a$ and $b$, returns a unique integer $c$.

This algorithm works by repeatedly dividing $a + bi$ by $(-1 + i)$.

Within the loop, we check to see if the number is odd. If $a + b$ is odd,
we know the least significant bit is $1$. And we can always subtract by
one by subtracting one from $a$.

That guarantees us that the value is divisible by $(-1 + i)$. Division is
by multiplication by $(i + 1) / (i + 1)$:

\[
\frac{a+bi}{-1+i} = \frac{(a+bi)(1+i)}{(-1+i)(1+i)} = 
\frac{a+ai+bi-b}{-1-1} = \frac{a-b}{-2}+\frac{(a+b)i}{-2}
\]

\begin{code}

abi2ido :: Bits a => (a, a) -> a
abi2ido (a, b) = f 1 0 a b
  where f x i a b | a' == 0 && b' == 0 = i'
                  | otherwise = f x' i' a'' b'
          where odd = (a + b) .&. 1
                a' = a - odd
                i' = i + x * odd
                a'' = divn2 $ a' - b
                b' = divn2 $ a' + b
                x' = shiftL x 1
                divn2 = (`shiftR` 1) . negate

\end{code}

\end{document}
