#!/usr/bin/env sage
# SLK2 Polynomial Vulnerability Analyzer - FIXED VERSION
# More accurate for cryptographic analysis

def SLK2_check(f):
    """
    Check SLK2 condition: Returns True if polynomial fails SLK2 test.
    But note: Failure doesn't automatically mean insecure for crypto.
    """
    from sage.all import ZZ, primes
    
    coeffs = f.coefficients(sparse=False)
    
    # Check each non-constant term (i > 0)
    for i in range(1, len(coeffs)):
        b = coeffs[i]
        if b == 0:
            continue
            
        # Check if b is divisible by ALL primes? No polynomial (except constant multiples) satisfies this.
        # Actually, SLK2 theorem says: If ∃ term b*y^i with i>0 and ∃ prime p such that p∤b, then (f) not maximal.
        # So ANY non-constant polynomial with any coefficient not divisible by some prime fails.
        # This includes almost all polynomials used in crypto!
        
        # The REAL cryptographic concern is: if f is reducible over QQ, or factors mod q into very small factors.
        
    # For practical purposes, we note the SLK2 condition but don't use it as a rejection criterion
    return True  # Almost all non-constant polynomials fail SLK2

def analyze_crypto_poly(f, q=None, name="Custom"):
    """
    Better analysis focusing on ACTUAL cryptographic risks
    """
    print("=" * 70)
    print(f"ANALYSIS FOR: {name}")
    print(f"Polynomial: {f}")
    if q:
        print(f"Modulus q: {q}")
    print("=" * 70)
    
    # 1. SLK2 note (not a rejection criterion)
    print("\n[1] ALGEBRAIC STRUCTURE:")
    slk2_fails = SLK2_check(f)
    print("   • SLK2 condition: (f) is NOT maximal in ℤ[x]")
    print("     (This is true for almost all non-constant polynomials)")
    print("     Does NOT automatically mean insecure for cryptography")
    
    # 2. Irreducibility over QQ (IMPORTANT!)
    print("\n[2] IRREDUCIBILITY OVER ℚ:")
    if f.is_irreducible():
        print("   ✓ Irreducible over ℚ - GOOD")
        irreducibility = True
    else:
        fac = f.factor()
        print(f"   ✗ REDUCIBLE over ℚ: {fac}")
        print("     WARNING: High risk for cryptography!")
        irreducibility = False
    
    # 3. Factorization modulo q (CRITICAL!)
    if q:
        print(f"\n[3] FACTORIZATION MODULO q={q}:")
        try:
            Fq = GF(q) if q.is_prime() else IntegerModRing(q)
            f_mod = f.change_ring(Fq)
            factors = f_mod.factor()
            
            if len(factors) == 1:
                print(f"   ✓ Remains irreducible modulo {q} - EXCELLENT")
                print(f"     Factor: {factors}")
                mod_factorization = "irreducible"
                risk_level = "LOW"
            else:
                degrees = [deg for _, deg in factors]
                min_deg = min(degrees)
                n = f.degree()
                
                print(f"   Factors into {len(factors)} factors: {factors}")
                print(f"   Minimum factor degree: {min_deg}")
                print(f"   Maximum factor degree: {max(degrees)}")
                
                # Risk assessment
                if min_deg == 1:
                    print("   ⚠️  CRITICAL: Linear factors present!")
                    print("     → Vulnerable to subfield attacks")
                    risk_level = "CRITICAL"
                elif min_deg < n/8:
                    print(f"   ⚠️  HIGH RISK: Very small factor degree ({min_deg} << {n})")
                    risk_level = "HIGH"
                elif min_deg < n/4:
                    print(f"   ⚠️  MODERATE RISK: Small factor degree ({min_deg} < {n}/4)")
                    risk_level = "MODERATE"
                else:
                    print(f"   ✓ ACCEPTABLE: All factors have degree ≥ {n}/4")
                    risk_level = "LOW"
                    
                mod_factorization = f"{len(factors)} factors, min degree {min_deg}"
        except Exception as e:
            print(f"   Error in factorization: {e}")
            mod_factorization = "error"
            risk_level = "UNKNOWN"
    
    # 4. Cryptographic recommendation
    print("\n[4] CRYPTOGRAPHIC ASSESSMENT:")
    
    if not irreducibility:
        print("   ✗ REJECT: Polynomial reducible over ℚ")
        print("     → Certain to factor modulo infinitely many primes")
        print("     → High risk of algebraic attacks")
    
    elif q and 'risk_level' in locals() and risk_level == "CRITICAL":
        print("   ✗ REJECT: Linear factors modulo q")
        print("     → Vulnerable to subfield attacks")
        print("     → Security reduction broken")
    
    elif q and 'risk_level' in locals() and risk_level == "HIGH":
        print("   ⚠️  HIGH RISK: Very small factors modulo q")
        print("     → Consider using different polynomial or modulus")
    
    elif q and 'risk_level' in locals() and risk_level == "MODERATE":
        print("   ⚠️  MODERATE RISK: Acceptable for Module-LWE")
        print("     → Kyber uses similar structure")
        print("     → Security relies on module rank")
    
    elif q and 'risk_level' in locals() and risk_level == "LOW":
        print("   ✓ ACCEPTABLE: Good algebraic structure")
    
    elif not q:
        print("   ⚠️  Cannot assess without modulus q")
        print("     Provide modulus for complete analysis")
    
    else:
        print("   ✓ ACCEPTABLE for further analysis")
    
    print("\n" + "=" * 70)
    return irreducibility

# ============================================
# TEST CASES - With better interpretation
# ============================================

print("\n" + "="*70)
print("SLK2 CRYPTOGRAPHIC ANALYZER - FIXED VERSION")
print("Understanding actual cryptographic risks")
print("="*70 + "\n")

R.<x> = ZZ[]

# Test 1: R.EMBLEM (actually broken)
print("\nTEST 1: R.EMBLEM (Historically Broken - Should reject)")
f1 = x^256 + x^128 + 1
q1 = 7681
analyze_crypto_poly(f1, q1, "R.EMBLEM x^256 + x^128 + 1")

# Test 2: Kyber (NIST standard - Should accept with caveats)
print("\n\nTEST 2: Kyber (ML-KEM) NIST Standard")
f2 = x^256 + 1
q2 = 3329
analyze_crypto_poly(f2, q2, "Kyber x^256 + 1")

# Test 3: NTRU Prime (Secure design - Should accept)
print("\n\nTEST 3: NTRU Prime (Secure by design)")
f3 = x^761 - x - 1
q3 = 4591
analyze_crypto_poly(f3, q3, "NTRU Prime x^761 - x - 1")

print("\n" + "="*70)
print("ANALYSIS COMPLETE")
print("="*70)

# Bonus: Show the issue with our original SLK2 interpretation
print("\n" + "="*70)
print("KEY INSIGHT:")
print("="*70)
print("The SLK2 theorem says: If f has a term b*x^i (i>0) where")
print("b is not divisible by some prime p, then (f) is not maximal in ℤ[x].")
print("\nBUT: Almost all cryptographic polynomials fail this!")
print("• x^256 + 1 fails (coefficient 1 not divisible by 2)")
print("• x^761 - x - 1 fails (coefficient 1 not divisible by 2)")
print("• Yet these are NIST-approved secure schemes!")
print("\nThe REAL security depends on:")
print("1. Irreducibility over ℚ")
print("2. Factorization pattern modulo q")
print("3. Module structure (for Module-LWE)")
print("="*70)
