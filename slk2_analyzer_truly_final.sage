#!/usr/bin/env sage
# SLK2 Polynomial Analyzer - TRULY FINAL BUG-FIXED VERSION

def analyze_polynomial_truly_correct(f, q=None, name="Custom"):
    """
    FINAL correct analysis with bug fixes
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
                # CORRECT: Get degrees of polynomials, NOT multiplicities
                degrees = [poly.degree() for poly, mult in factors]
                min_deg = min(degrees)
                max_deg = max(degrees)
                
                print(f"   Factors into {len(factors)} irreducible factors")
                print(f"   Actual factor degrees: {sorted(set(degrees))}")
                print(f"   Minimum factor degree: {min_deg}")
                print(f"   Maximum factor degree: {max_deg}")
                
                # Show first 3 factors as examples
                print(f"   Example factors (polynomial, multiplicity):")
                for i, (poly, mult) in enumerate(factors[:3]):
                    print(f"     {i+1}. {poly} (degree {poly.degree()}, multiplicity {mult})")
                if len(factors) > 3:
                    print("     ...")
                
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
# TEST WITH TRULY CORRECTED ANALYSIS
# ============================================

print("\n" + "="*70)
print("CRYPTOGRAPHIC POLYNOMIAL ANALYZER - TRULY FINAL VERSION")
print("With ACTUALLY corrected degree analysis")
print("="*70 + "\n")

R.<x> = ZZ[]

print("DEMONSTRATING THE BUG FIX:")
print("-" * 70)
print("Old bug: We were reading the multiplicity (1) as the degree")
print("New fix: We read poly.degree() to get actual degree")

# Test Kyber to show the fix
print("\n\nTEST: Kyber (x^256 + 1)")
f2 = x^256 + 1
q2 = 3329
analyze_polynomial_truly_correct(f2, q2, "Kyber")

# Test the others
print("\n\nTEST: R.EMBLEM (x^256 + x^128 + 1)")
f1 = x^256 + x^128 + 1
q1 = 7681
analyze_polynomial_truly_correct(f1, q1, "R.EMBLEM")

print("\n\nTEST: NTRU Prime (x^761 - x - 1)")
f3 = x^761 - x - 1
q3 = 4591
analyze_polynomial_truly_correct(f3, q3, "NTRU Prime")

print("\n" + "="*70)
print("FINAL LESSONS:")
print("="*70)
print("1. SLK2: Pure math result - not a security criterion")
print("2. Real crypto security criteria:")
print("   - Irreducible over ℚ (MUST)")
print("   - No linear factors modulo q (CRITICAL)")
print("   - Small factors risk depends on scheme")
print("3. Kyber: Quadratic factors OK for Module-LWE")
print("4. NTRU Prime: Irreducible mod q - ideal for Ring-LWE")
print("5. Always check: poly.degree(), not multiplicity!")
print("="*70)
