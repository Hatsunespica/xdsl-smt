import matplotlib.pyplot as plt
import re


def plot(filepath: str, key_pattern: str, plot_udis: bool = True):
    a, b, c = key_pattern.split("_")
    b = int(b)
    row_pattern = re.compile(
        rf"{a}_(\d+)_{c}\t([\d.]+)%\t([\d.]+)%\t([\d.]+)\t([\d.]+)"
    )

    indices = []
    sound_vals = []
    uexact_vals = []
    udis_vals = []
    cost_vals = []

    with open(filepath, "r") as f:
        for line in f:
            match = row_pattern.match(line)
            if match:
                idx, sound, uexact, udis, cost = match.groups()
                indices.append(int(idx))
                sound_vals.append(float(sound))
                uexact_vals.append(float(uexact))
                udis_vals.append(float(udis))
                cost_vals.append(float(cost) * 100)

    if not indices:
        print(f"No matches found for key pattern {key_pattern}")
        return

    fig, ax1 = plt.subplots(figsize=(12, 6))

    # Plot left-axis values
    ax1.plot(indices, sound_vals, label="Sound%", color="tab:blue", linewidth=2)
    ax1.plot(indices, uexact_vals, label="UExact%", color="tab:orange", linewidth=2)
    ax1.plot(indices, cost_vals, label="Cost (x100)", color="tab:red", linewidth=2)

    ax1.axvline(
        x=b, color="gray", linestyle="--", linewidth=1.5, label=f"Best Step (b = {b})"
    )
    ax1.text(
        b + 2,
        95,
        f"b = {b}",
        rotation=90,
        verticalalignment="top",
        color="gray",
        fontsize=10,
    )

    ax1.set_ylabel("%", fontsize=12)
    ax1.set_ylim(0, 100)
    ax1.set_xlabel("Step", fontsize=12)
    ax1.grid(True, linestyle="--", alpha=0.5)

    # Optional: plot UDis on right y-axis
    if plot_udis:
        ax2 = ax1.twinx()
        ax2.plot(
            indices,
            udis_vals,
            label="UDis (right axis)",
            color="tab:green",
            linewidth=2.5,
            linestyle="--",
            alpha=0.8,
        )
        ax2.set_ylabel("UDis", fontsize=12, color="tab:green")
        ax2.tick_params(axis="y", labelcolor="tab:green")

        udis_min, udis_max = min(udis_vals), max(udis_vals)
        delta = udis_max - udis_min
        ax2.set_ylim(udis_min - 0.1 * delta, udis_max + 0.1 * delta)

        # Merge legends from both axes
        lines1, labels1 = ax1.get_legend_handles_labels()
        lines2, labels2 = ax2.get_legend_handles_labels()
        ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper right")
    else:
        # Only left-axis legend
        ax1.legend(loc="upper right")

    plt.title(f"Metrics for Iteration {a} Process {c}", fontsize=14)
    plt.tight_layout()
    plt.show()
