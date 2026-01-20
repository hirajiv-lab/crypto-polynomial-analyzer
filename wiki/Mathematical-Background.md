# Mathematical Background

## SLK2 Theorem Statement
Let B be a UFD, and A := B[y] the polynomial ring. Let f be a polynomial that has a term by^i with i > 0 such that b is not divisible by some prime element p in B. Prove that the ideal (f) is not maximal.

## Cryptographic Interpretation

### Original Context
- B = ℤ (integers, a UFD)
- A = ℤ[x] (polynomial ring over integers)
- f ∈ ℤ[x] a polynomial for cryptographic use

### Mathematical Consequence
If f has any non-constant term with coefficient not divisible by some prime p, then:
- (f) is not a maximal ideal in ℤ[x]
- ℤ[x]/(f) is not a field
- f is either reducible over ℚ or factors modulo many primes

### Security Implications
1. Non-maximal ideal structure may enable algebraic attacks
2. Reducibility over ℚ guarantees factorization modulo infinitely many primes
3. Small-degree factors modulo q enable subfield attacks
4. Linear factors (degree 1) are particularly dangerous

## Key Mathematical Concepts

### Maximal Ideals
An ideal I in ring R is maximal if:
- I ≠ R
- For any ideal J with I ⊆ J ⊆ R, either J = I or J = R

In ℤ[x], maximal ideals have form (p, g(x)) where:
- p is prime in ℤ
- g(x) is irreducible modulo p

### Factorization Theorems
1. **Dedekind's Theorem**: If f is irreducible over ℚ, then for infinitely many primes p, f remains irreducible modulo p
2. **Chinese Remainder Theorem**: If f factors modulo q, the ring ℤ_q[x]/(f) decomposes into product of smaller rings

### Subfield Attacks
When f(x) factors as f₁(x)f₂(x) modulo q, an attacker can:
- Map RLWE instance to smaller rings via CRT
- Solve easier problems in subfields
- Combine solutions to attack original instance

## References
1. Lang, S. "Algebra"
2. Cohen, H. "A Course in Computational Algebraic Number Theory"
3. Peikert, C. "A Decade of Lattice Cryptography"
