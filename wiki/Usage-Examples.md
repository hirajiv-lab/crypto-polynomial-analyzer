# Usage Examples

## Basic Analysis

### Analyze Standard Polynomials

Output shows analysis for:
1. R.EMBLEM (historically broken)
2. Kyber (NIST standard)
3. NTRU Prime (secure design)

### Quick Check for Custom Polynomial
# Create Usage-Examples.md wiki page
cat > Usage-Examples.md << 'EOF'
# Usage Examples

## Basic Analysis

### Analyze Standard Polynomials
Run full analysis on included test cases
sage slk2_analyzer_truly_final.sage

text

Output shows analysis for:
1. R.EMBLEM (historically broken)
2. Kyber (NIST standard)
3. NTRU Prime (secure design)

### Quick Check for Custom Polynomial
sage quick_crypto_check.sage

text

## Command Line Examples

### Example 1: Check Specific Polynomial
sage -c "
R.<x> = ZZ[]
f = x^256 + x^128 + 1 # Polynomial
q = 7681 # Modulus

print('Polynomial:', f)
print('Modulus:', q)

Check irreducibility over Q
if not f.is_irreducible():
print('REJECT: Reducible over Q')
print('Factorization:', f.factor())
else:
print('Irreducible over Q - good')

text
# Check factorization modulo q
Fq = GF(q)
f_mod = f.change_ring(Fq)
factors = f_mod.factor()

print('Factorization modulo', q, ':', factors)
if any(poly.degree() == 1 for poly, mult in factors):
    print('WARNING: Linear factors present')
"

text

### Example 2: Batch Testing
Create test file test_polys.sage
cat > test_polys.sage << 'TEST'
R.<x> = ZZ[]
test_cases = [
('Kyber', x^256 + 1, 3329),
('Custom1', x^512 + 7*x^256 + 1, 12289),
('Custom2', x^128 + x^64 + 1, 7681),
]

for name, f, q in test_cases:
print('\n===', name, '===')
print('Polynomial:', f)

text
if not f.is_irreducible():
    print('REJECT: Reducible over Q')
    continue
    
Fq = GF(q)
factors = f.change_ring(Fq).factor()
min_deg = min(poly.degree() for poly, mult in factors)

if min_deg == 1:
    print('REJECT: Linear factors modulo', q)
elif min_deg == 2:
    print('ACCEPT: Quadratic factors (Module-LWE safe)')
else:
    print('ACCEPT: Minimum factor degree', min_deg)
TEST

Run batch test
sage test_polys.sage

text

## Python Integration

### Basic Wrapper
```python
import subprocess
import json

def analyze_polynomial(coeffs, q):
    """Analyze polynomial using SageMath"""
    # Convert coefficients to SageMath syntax
    coeff_str = ' + '.join(f'{c}*x^{i}' for i, c in enumerate(reversed(coeffs)) if c != 0)
    
    cmd = f"""
    R.<x> = ZZ[]
    f = {coeff_str}
    q = {q}
    
    result = {{'polynomial': str(f), 'modulus': q}}
    
    # Check irreducibility
    if not f.is_irreducible():
        result['status'] = 'REJECT'
        result['reason'] = 'reducible_over_Q'
        result['factorization'] = str(f.factor())
    else:
        Fq = GF(q)
        factors = f.change_ring(Fq).factor()
        result['factors'] = str(factors)
        
        min_deg = min(poly.degree() for poly, mult in factors)
        result['min_factor_degree'] = min_deg
        
        if min_deg == 1:
            result['status'] = 'REJECT'
            result['reason'] = 'linear_factors'
        elif min_deg == 2:
            result['status'] = 'ACCEPT'
            result['reason'] = 'quadratic_factors'
        else:
            result['status'] = 'ACCEPT'
            result['reason'] = f'factor_degree_{min_deg}'
    
    import json
    print(json.dumps(result))
    """
    
    process = subprocess.run(['sage', '-c', cmd], 
                           capture_output=True, text=True)
    
    if process.returncode == 0:
        return json.loads(process.stdout)
    else:
        return {'error': process.stderr}

# Example usage
result = analyze_polynomial([1, 0, 0, 0, 1], 3329)  # x^4 + 1
print(json.dumps(result, indent=2))
Advanced Usage
Performance Testing
text
# Time factorization for different degrees
for n in [128, 256, 512, 1024]:
    sage -c "
    import time
    R.<x> = ZZ[]
    f = x^n + 1
    q = 3329
    
    start = time.time()
    Fq = GF(q)
    factors = f.change_ring(Fq).factor()
    elapsed = time.time() - start
    
    print(f'Degree {n}: {elapsed:.2f} seconds, {len(factors)} factors')
    "
Generate Report
text
# Generate analysis report
sage -c "
R.<x> = ZZ[]
polynomials = [
    ('x^256+1', x^256 + 1),
    ('x^512+7x^256+1', x^512 + 7*x^256 + 1),
]

print('Polynomial Analysis Report')
print('=' * 50)

for name, f in polynomials:
    print(f'\\n{name}:')
    print(f'  Degree: {f.degree()}')
    print(f'  Irreducible over Q: {f.is_irreducible()}')
    
    if not f.is_irreducible():
        print(f'  Factorization: {f.factor()}')
"
