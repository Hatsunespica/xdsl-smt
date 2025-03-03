import matplotlib.pyplot as plt
def print_figure(data: list[list[float]], output_dir: str, file_name: str) -> None:
    plt.figure(figsize=(10, 6))
    x = list(range(0, len(data[0])))
    for y in data:
        plt.step(x, y, where='mid', color="black", alpha=0.5)

    # plt.yscale('log')
    # plt.xticks(np.arange(min(x), max(x)+1, 1))

    plt.xlabel("Step")
    plt.ylabel("Cost")
    plt.savefig(f"{output_dir}/{file_name}.png", dpi=300, bbox_inches='tight')
    # plt.show()