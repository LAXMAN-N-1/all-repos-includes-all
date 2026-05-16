from app.utils.password_utils import verify_password

# Test vendor password
vendor_hash = "$2b$12$zovgN2drsPEeR5un/fz9/uZS3tdt4/qYwm//hGXiW9XvNUJ74RLZS"
test_passwords = ["vendor123", "laxman123"]

for pwd in test_passwords:
    result = verify_password(pwd, vendor_hash)
    print(f"Password '{pwd}': {result}")
