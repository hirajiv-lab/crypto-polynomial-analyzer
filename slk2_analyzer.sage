#!/usr/bin/env sage
# SLK2 Polynomial Vulnerability Analyzer
# For Post-Quantum Cryptography Parameter Analysis

def SLK2_check(f, max_prime_check=20):
    """
    Check if polynomial f in ZZ[x] satisfies SLK2 vulnerability condition.
    """
    from sage.all import ZZ, primes
    
    coeffs = f.coefficients(sparse=False)
    vulnerable_primes = []
    
    for i in range(1, len(coeffs)):
        b = coeffs[i]
        if b == 0:
            continue
            
        for p in primes(max_prime_check):
            if b % p != 0:
                vulnerable_primes.append((p, i, b))
                break
    
    is_vulnerable = len(vulnerable_primes) > 0
    
    explanation = ""
    if is_vulnerable:
        explanation = f"VULNERABLE by SLK2: Found {len(vulnerable_primes)} term(s)\n"
        for p, i, b in vulnerable_primes[:3]:
            explanation += f"  Term x^{i}: coefficient {b} not divisible by prime {p}\n"
        explanation += "⇒ (f) is NOT maximal in ZZ[x] ⇒ likely reducible over QQ"
    else:
        explanation = "No SLK2 vulnerability found."
    
    return is_vulnerable, explanation, vulnerable_primes

def analyze_polynomial(f, q=None, name="Custom"):
    """
    Full analysis of a polynomial for cryptographic use.
    """
    print("=" * 70)
    print(f"ANALYSIS FOR: {name}")
    print(f"Polynomial: {f}")
    if q:
        print(f"Modulus q: {q}")
    print("=" * 70)
    
    # 1. SLK2 check
    vuln, explanation, _ = SLK2_check(f)
    print("\n[1] SLK2 MAXIMAL IDEAL TEST:")
    print(explanation)
    
    # 2. Factorization over QQ
    print("\n[2] FACTORIZATION OVER RATIONAL NUMBERS:")
    if f.is_irreducible():
        print("✓ Irreducible over QQ")
    else:
        fac = f.factor()
        print(f"✗ REDUCIBLE over QQ: {fac}")
    
    # 3. Factorization modulo q
    if q:
        print(f"\n[3] FACTORIZATION MODULO q={q}:")
        try:
            Fq = GF(q) if q.is_prime() else IntegerModRing(q)
            f_mod = f.change_ring(Fq)
            factors = f_mod.factor()
            print(f"  {factors}")
            
            # Subfield risk assessment
            if len(factors) > 1:
                degrees = [deg for _, deg in factors]
                min_deg = min(degrees)
                n = f.degree()
                if min_deg < n/4:
                    print(f"  ⚠️ HIGH SUBFIELD RISK: Small factor degree {min_deg} << {n}")
                elif min_deg < n/2:
                    print(f"  ⚠️ MODERATE SUBFIELD RISK: Factor degree {min_deg} < {n/2}")
        except Exception as e:
            print(f"  Error: {e}")
    
    # 4. Recommendation
    print("\n[4] RECOMMENDATION:")
    if vuln or not f.is_irreducible():
        print("✗ REJECT this polynomial for RLWE/MLWE schemes.")
    elif q and len(factors) > 1 and min_deg < n/4:
        print("✗ REJECT: High subfield attack risk.")
    else:
        print("✓ ACCEPTABLE for further analysis.")
    
    print("=" * 70)
    return vuln

# ============================================
# TEST CASES
# ============================================

print("\n" + "="*70)
print("SLK2 CRYPTOGRAPHIC POLYNOMIAL ANALYZER")
print("Running test cases...")
print("="*70 + "\n")

# Define polynomial ring
R.<x> = ZZ[]

# Test 1: R.EMBLEM (broken candidate)
print("\nTEST 1: R.EMBLEM (Historically Broken)")
f1 = x^256 + x^128 + 1
q1 = 7681
analyze_polynomial(f1, q1, "R.EMBLEM x^256 + x^128 + 1")

# Test 2: Kyber's polynomial
print("\n\nTEST 2: Kyber (ML-KEM) Standard")
f2 = x^256 + 1
q2 = 3329
analyze_polynomial(f2, q2, "Kyber x^256 + 1")

# Test 3: Dangerous custom polynomial
print("\n\nTEST 3: Custom (Dangerous)")
f3 = x^512 + 7*x^256 + 1
q3 = 12289
analyze_polynomial(f3, q3, "Custom x^512 + 7x^256 + 1")

# Test 4: NTRU Prime
print("\n\nTEST 4: NTRU Prime (Carefully Designed)")
f4 = x^761 - x - 1
q4 = 4591
analyze_polynomial(f4, q4, "NTRU Prime x^761 - x - 1")

print("\n" + "="*70)
print("ANALYSIS COMPLETE")
print("="*70)
