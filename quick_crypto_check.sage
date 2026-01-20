#!/usr/bin/env sage
# Quick cryptographic polynomial checker

def quick_check(poly_coeffs, q):
    """
    Quick safety check for cryptographic polynomial
    
    Args:
        poly_coeffs: List of coefficients from highest to lowest degree
        q: Modulus (prime or composite)
    
    Returns:
        True if acceptable, False if rejected
    """
    R.<x> = ZZ[]
    
    # Create polynomial from coefficients
    f = sum(c*x^i for i, c in enumerate(reversed(poly_coeffs)))
    
    print("=" * 60)
    print(f"Polynomial: {f}")
    print(f"Modulus: {q}")
    print("=" * 60)
    
    # 1. Irreducible over ℚ?
    if not f.is_irreducible():
        print("\n✗ REJECT: Polynomial is reducible over ℚ")
        print(f"  Factorization: {f.factor()}")
        print("  → Will factor modulo infinitely many primes")
        print("  → High risk of algebraic attacks")
        return False
    
    print("\n✓ Irreducible over ℚ - GOOD")
    
    # 2. Factorization modulo q
    try:
        if q.is_prime():
            Fq = GF(q)
        else:
            Fq = IntegerModRing(q)
        
        f_mod = f.change_ring(Fq)
        factors = f_mod.factor()
        
        if len(factors) == 1:
            print("✓ Irreducible modulo q - EXCELLENT")
            print(f"  Factor: {factors}")
            return True
        
        # Get minimum factor degree
        min_deg = min(poly.degree() for poly, mult in factors)
        n = f.degree()
        
        print(f"\nFactorization modulo {q}:")
        print(f"  Number of factors: {len(factors)}")
        print(f"  Minimum factor degree: {min_deg}")
        print(f"  Maximum factor degree: {max(poly.degree() for poly, mult in factors)}")
        
        # Show first few factors
        print(f"  First 3 factors:")
        for i, (poly, mult) in enumerate(factors[:3]):
            print(f"    {i+1}. {poly} (degree {poly.degree()})")
        if len(factors) > 3:
            print("    ...")
        
        # Risk assessment
        if min_deg == 1:
            print("\n✗ REJECT: Linear factors present!")
            print("  → Vulnerable to subfield attacks")
            print("  → Security reduction broken")
            return False
        elif min_deg == 2:
            print("\n⚠️  CAUTION: Quadratic factors (like Kyber)")
            print("  → Acceptable for Module-LWE schemes")
            print("  → Security relies on module structure")
            return True
        elif min_deg < n/8:
            print(f"\n⚠️  HIGH RISK: Small factors (degree {min_deg} << {n})")
            print("  → Consider different polynomial or modulus")
            return True  # But with warning
        elif min_deg < n/4:
            print(f"\n⚠️  MODERATE RISK: Factor degree {min_deg}")
            print("  → Acceptable with proper security analysis")
            return True
        else:
            print(f"\n✓ ACCEPTABLE: All factors degree ≥ {n}/4")
            return True
            
    except Exception as e:
        print(f"\n⚠️  Error during factorization: {e}")
        print("  → Manual verification needed")
        return None  # Unknown

# Example usage
if __name__ == "__main__":
    print("QUICK CRYPTOGRAPHIC POLYNOMIAL CHECKER")
    print("=" * 60)
    
    # Example 1: Kyber polynomial
    print("\nExample 1: Kyber (x^256 + 1)")
    quick_check([1] + [0]*255 + [1], 3329)
    
    # Example 2: Dangerous polynomial
    print("\n\nExample 2: Dangerous (x^128 + x^64 + 1)")
    quick_check([1] + [0]*63 + [1] + [0]*63 + [1], 7681)
    
    print("\n" + "=" * 60)
    print("Quick check completed")
