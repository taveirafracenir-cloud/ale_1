import time
import os

frames = [
r"""
        (__)
        (oo) 
  /------\/ 
 / |    ||  
*  /\---/\ 
   ~~   ~~ 
""",
r"""
        (__)
        (oo) 
  /------\/ 
 / |    ||  
*  /\/--/\ 
   ~~   ~~ 
""",
r"""
        (__)
        (oo) 
  /------\/ 
 / |    ||  
*  /\--\/\ 
   ~~   ~~ 
"""
]

for i in range(6):  # repete a animação
    os.system('clear' if os.name == 'posix' else 'cls')
    print(frames[i % len(frames)])
    time.sleep(0.3)

os.system('clear' if os.name == 'posix' else 'cls')
print(frames[0])
print("\nA vaquinha diz: Oi, tudo bem? 🐄💖")
