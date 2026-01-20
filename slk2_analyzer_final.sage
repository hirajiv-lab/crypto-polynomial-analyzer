#!/usr/bin/env sage
# SLK2 Polynomial Analyzer - FINAL BUG-FIXED VERSION

def analyze_polynomial_correctly(f, q=None, name="Custom"):
    """
    Correct analysis focusing on actual cryptographic risks
    """
    print("=" * 70)
    print(f"ANALYSIS FOR: {name}")
    print(f"Polynomial: {f}")
    if q:
        print(f"Modulus q: {q}")
    print("=" * 70)
    
    n = f.degree()
    
    # 1. SLK2 note (informational only)
    print("\n[1] ALGEBRAIC STRUCTURE NOTE:")
    print("   • By SLK2 theorem: (f) is NOT maximal in ℤ[x]")
    print("     (True for almost all non-constant polynomials)")
    print("     This alone does NOT determine cryptographic security")
    
    # 2. Irreducibility over ℚ (CRITICAL)
    print("\n[2] IRREDUCIBILITY OVER ℚ:")
    if f.is_irreducible():
        print("   ✓ Irreducible over ℚ - ESSENTIAL for security")
        irreducibility = True
    else:
        fac = f.factor()
        print(f"   ✗ REDUCIBLE over ℚ: {fac}")
        print("     → AUTOMATIC REJECTION for cryptography")
        print("     → Will factor modulo infinitely many primes")
        irreducibility = False
    
    # 3. Factorization modulo q
    if q:
        print(f"\n[3] FACTORIZATION MODULO q={q}:")
        try:
            Fq = GF(q) if q.is_prime() else IntegerModRing(q)
            f_mod = f.change_ring(Fq)
            factors = f_mod.factor()
            
            if len(factors) == 1:
                print(f"   ✓ Remains irreducible modulo {q}")
                print(f"     Factor: {factors}")
                risk_level = "EXCELLENT"
            else:
                degrees = [deg for poly, deg in factors]
                min_deg = min(degrees)
                max_deg = max(degrees)
                
                print(f"   Factors into {len(factors)} factors")
                print(f"   Factor degrees: {sorted(set(degrees))}")
                print(f"   Minimum factor degree: {min_deg}")
                print(f"   Maximum factor degree: {max_deg}")
                
                # Show first 3 factors as examples
                print(f"   Example factors: {factors[:3]}{'...' if len(factors) > 3 else ''}")
                
                # CORRECTED RISK ASSESSMENT
                if min_deg == 1:
                    print("   ⚠️  CRITICAL: Linear factors present!")
                    print("     → Highly vulnerable to subfield attacks")
                    risk_level = "CRITICAL"
                elif min_deg == 2:
                    print("   ⚠️  MODERATE: Quadratic factors (like Kyber)")
                    print("     → Acceptable for Module-LWE schemes")
                    print("     → Security relies on module structure")
                    risk_level = "MODERATE"
                elif min_deg < n/8:
                    print(f"   ⚠️  HIGH RISK: Small factors (degree {min_deg} << {n})")
                    risk_level = "HIGH"
                elif min_deg < n/4:
                    print(f"   ⚠️  MODERATE RISK: Moderate factors (degree {min_deg})")
                    risk_level = "MODERATE"
                else:
                    print(f"   ✓ ACCEPTABLE: All factors degree ≥ {n}/4")
                    risk_level = "LOW"
        except Exception as e:
            print(f"   Error: {e}")
            risk_level = "UNKNOWN"
    
    # 4. Recommendation
    print("\n[4] RECOMMENDATION:")
    
    if not irreducibility:
        print("   ✗ REJECT: Reducible over ℚ")
    elif q and 'risk_level' in locals():
        if risk_level == "CRITICAL":
            print("   ✗ REJECT: Linear factors modulo q")
        elif risk_level == "HIGH":
            print("   ⚠️  HIGH RISK: Very small factors")
            print("     → Consider different polynomial or modulus")
        elif risk_level == "MODERATE":
            print("   ✓ ACCEPTABLE with caveats (like Kyber)")
            print("     → Module-LWE structure provides security")
        elif risk_level == "LOW":
            print("   ✓ ACCEPTABLE: Good factorization pattern")
        elif risk_level == "EXCELLENT":
            print("   ✓ EXCELLENT: Irreducible modulo q")
            print("     → Ideal for Ring-LWE schemes")
    elif not q:
        print("   ⚠️  Provide modulus q for complete analysis")
    else:
        print("   ✓ ACCEPTABLE for further analysis")
    
    print("\n" + "=" * 70)
    return irreducibility

# ============================================
# TEST WITH CORRECTED ANALYSIS
# ============================================

print("\n" + "="*70)
print("CRYPTOGRAPHIC POLYNOMIAL ANALYZER - FINAL VERSION")
print("With corrected degree analysis")
print("="*70 + "\n")

R.<x> = ZZ[]

# Test 1: R.EMBLEM (broken)
print("\nTEST 1: R.EMBLEM (x^256 + x^128 + 1)")
f1 = x^256 + x^128 + 1
q1 = 7681
analyze_polynomial_correctly(f1, q1, "R.EMBLEM")

# Test 2: Kyber (NIST standard)
print("\n\nTEST 2: Kyber (x^256 + 1)")
f2 = x^256 + 1
q2 = 3329
analyze_polynomial_correctly(f2, q2, "Kyber")

# Test 3: NTRU Prime
print("\n\nTEST 3: NTRU Prime (x^761 - x - 1)")
f3 = x^761 - x - 1
q3 = 4591
analyze_polynomial_correctly(f3, q3, "NTRU Prime")

# Test 4: Another example
print("\n\nTEST 4: x^128 + x^64 + x^32 + x^16 + 1")
f4 = x^128 + x^64 + x^32 + x^16 + 1
q4 = 12289
analyze_polynomial_correctly(f4, q4, "Cyclotomic-like")

print("\n" + "="*70)
print("KEY TAKEAWAYS:")
print("="*70)
print("1. SLK2 theorem is a pure math result")
print("2. It doesn't directly determine cryptographic security")
print("3. Real security depends on:")
print("   a) Irreducibility over ℚ (MOST IMPORTANT)")
print("   b) Factorization pattern modulo q")
print("   c) Module structure vs Ring structure")
print("4. Kyber is secure despite factoring modulo q")
print("   because it uses Module-LWE, not pure Ring-LWE")
print("="*70)
