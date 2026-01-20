# Security Analysis

## Risk Levels

### 1. Reducible Over ℚ
- Status: REJECT
- Reason: Guarantees factorization modulo infinitely many primes
- Example: x^256 + x^128 + 1

### 2. Linear Factors Modulo q
- Status: REJECT
- Reason: Enables subfield attacks
- Example: Factors containing (x + a)

### 3. Quadratic Factors Modulo q
- Status: ACCEPT
- Reason: Secure for Module-LWE schemes
- Example: Kyber (x^256 + 1) mod 3329

### 4. Irreducible Modulo q
- Status: ACCEPT
- Reason: Ideal for Ring-LWE schemes
- Example: NTRU Prime (x^761 - x - 1) mod 4591

## Analysis Process
1. Check irreducibility over ℚ
2. Factor modulo q
3. Check minimum factor degree
4. Assign risk level based on degree
