# Cryptographic Polynomial Analyzer

A SageMath-based tool for analyzing polynomial choices in post-quantum cryptography, based on the SLK2 maximal ideal theorem.

## Purpose

This tool helps cryptographers and security engineers evaluate polynomial choices for lattice-based cryptography schemes (Kyber, NTRU, etc.) by checking:

1. **Irreducibility over ℚ** (MOST IMPORTANT)
2. **Factorization pattern modulo q**
3. **Subfield attack risk assessment**
4. **SLK2 maximal ideal condition** (informational)

## Background

Based on the SLK2 mathematical theorem:
> Let B be a UFD, and A := B[y] the polynomial ring. Let f be a polynomial that has a term byⁱ with i > 0 such that b is not divisible by some prime element p in B. Prove that the ideal (f) is not maximal.

This mathematical insight translates to practical cryptographic analysis: polynomials that generate non-maximal ideals may be vulnerable to algebraic attacks if they also factor into small-degree polynomials modulo the scheme's modulus.

## Files

- `slk2_analyzer.sage` - Initial implementation
- `slk2_analyzer_fixed.sage` - Improved version
- `slk2_analyzer_final.sage` - Final bug-fixed version
- `slk2_analyzer_truly_final.sage` - Completely corrected version
- `quick_crypto_check.sage` - Simple checker for production use

## Installation

```bash
# Install SageMath via conda
conda create -n sage sage python=3.11
conda activate sage

# Or install via package manager
# sudo apt install sagemath
# Run the main analyzer
sage slk2_analyzer_truly_final.sage

# Test a custom polynomial
sage -c "
R.<x> = ZZ[]
f = x^256 + 1  # Your polynomial here
q = 3329       # Your modulus here
print('Testing:', f)
if not f.is_irreducible():
    print('✗ REJECT: Reducible over ℚ')
else:
    Fq = GF(q)
    factors = f.change_ring(Fq).factor()
    print('Factorization mod q:', factors)
"
The analyzer includes tests for:

R.EMBLEM (historically broken NIST candidate)

Kyber (NIST-standardized ML-KEM)

NTRU Prime (carefully designed secure scheme)

Key Findings
SLK2 condition alone doesn't determine security - Almost all cryptographic polynomials fail it

Irreducibility over ℚ is mandatory - Reducible polynomials are automatically insecure

Linear factors modulo q are critical vulnerabilities - Enable subfield attacks

Quadratic factors are acceptable for Module-LWE (like Kyber)

Irreducible modulo q is ideal for Ring-LWE (like NTRU Prime)

License
MIT License - See LICENSE file for details

Contributing
Fork the repository

Create a feature branch

Add tests for new polynomials

Submit a pull request
