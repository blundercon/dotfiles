import matplotlib.pyplot as plt

# Portfolio data
holdings = [
    {"name": "GOLDBEES", "units": 690, "last_price": 91.26},
    {"name": "SILVERBEES", "units": 10, "last_price": 123.66},
    {"name": "TCS", "units": 1, "last_price": 3134.05},
    {"name": "WAAREEENER", "units": 13, "last_price": 3634.5},
]

# Calculate current value per holding
labels = [h["name"] for h in holdings]
values = [h["units"] * h["last_price"] for h in holdings]

# Plot pie chart
plt.figure(figsize=(8, 8))
plt.pie(values, labels=labels, autopct='%1.1f%%', startangle=140)
plt.title('Portfolio Allocation by Value')
plt.axis('equal')
plt.show()
