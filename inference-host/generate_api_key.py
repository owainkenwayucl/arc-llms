import secrets
import string

print("".join(secrets.choice(string.ascii_letters+string.digits) for _ in range(64)))
