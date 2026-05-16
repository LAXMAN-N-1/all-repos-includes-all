from app.utils.password_utils import verify_password

hashed = "$2b$12$Wxeok75zQKPtvZtoKRxW2u0W1r2AyVx3mIyToFUtq.62HLG.VigQG"
plain = "vendor123"

result = verify_password(plain, hashed)
print(f"Verification result: {result}")
