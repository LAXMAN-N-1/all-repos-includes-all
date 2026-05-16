from app.utils.password_utils import verify_password

hashed = "$2b$12$Is2BlabAxAEwfIJxg9fv2eu7WNjkRd9h0ldzAk10JfQEHpOrkNveG"
plain = "admin123"

result = verify_password(plain, hashed)
print(f"Verification result: {result}")
