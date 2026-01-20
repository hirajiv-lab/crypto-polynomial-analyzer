# Documentation

## Mathematical Background

### SLK2 Theorem
The original problem states:

> Let B be a UFD, and A := B[y] the polynomial ring. Let f be a polynomial that has a term byⁱ with i > 0 such that b is not divisible by some prime element p in B. Prove that the ideal (f) is not maximal.

**Translation to cryptography:**
- B = ℤ (integers, which is a UFD)
- A = ℤ[x] (polynomial ring over integers)
- If f ∈ ℤ[x] has any non-constant term whose coefficient is not divisible by some prime p, then (f) is not maximal in ℤ[x]

### Cryptographic Implications

A polynomial f generating a non-maximal ideal means:
1. ℤ[x]/(f) is not a field
2. f is reducible over ℚ (rational numbers) or will factor modulo many primes
3. This algebraic structure can be exploited in attacks

## Tool Architecture

### Files Overview

1. **slk2_analyzer.sage** - Initial implementation
   - Basic SLK2 check
   - Factorization analysis
   - **Issue**: Too strict - rejects all polynomials

2. **slk2_analyzer_fixed.sage** - Improved version
   - Better risk assessment
   - Distinguishes between different factor degrees
   - **Issue**: Still has bugs in degree calculation

3. **slk2_analyzer_final.sage** - Final version
   - Corrected degree analysis
   - Proper risk categorization
   - **Issue**: Still reading multiplicity as degree

4. **slk2_analyzer_truly_final.sage** - Completely corrected
   - Uses `poly.degree()` instead of multiplicity
   - Accurate risk assessment
   - Production-ready

5. **quick_crypto_check.sage** - Simple checker
   - Minimal dependencies
   - Easy to integrate into CI/CD pipelines

## Usage Examples

### Basic Analysis
```bash
sage slk2_analyzer_truly_final.sage
# In SageMath
R.<x> = ZZ[]
f = x^512 + 7*x^256 + 1  # Your polynomial
q = 12289                # Your modulus

# Check irreducibility
if not f.is_irreducible():
    print("REJECT: Reducible over ℚ")
else:
    # Check factorization modulo q
    Fq = GF(q)
    factors = f.change_ring(Fq).factor()
    min_deg = min(poly.degree() for poly, mult in factors)
    if min_deg == 1:
        print("REJECT: Linear factors modulo q")
import subprocess
import json

def analyze_polynomial(coeffs, q):
    """Call SageMath analyzer from Python"""
    cmd = [
        "sage", "-c",
        f"""
        R.<x> = ZZ[]
        f = sum([{coeffs[i]}*x^{len(coeffs)-1-i} for i in range({len(coeffs)})])
        q = {q}
        print({{'polynomial': str(f), 'modulus': q}})
        """
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout
3. NTRU Prime (Secure)
Polynomial: x⁷⁶¹ - x - 1

Issues: None

Security: Irreducible modulo 4591

Result: Secure by design

Best Practices
Never use polynomials reducible over ℚ

Avoid linear factors modulo your modulus

Prefer standardized polynomials (Kyber, NTRU Prime)

Always test with multiple moduli

Get peer review for custom parameters

References
NIST Post-Quantum Cryptography Standardization

Kyber Specification

NTRU Prime Specification

Subfield Attack Paper - CRYPTO 2016
