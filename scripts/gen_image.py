from python_utils import unsound, profile, precision, mcmc
import matplotlib.pyplot as plt
import os

output_folder = "./outputs/mytest/"
test_name = "knownBitsShlRHSConstant"
DEBUG_FILE = "debug.log"
INFO_FILE = "info.log"


def get_debug_file():
    return os.path.join(output_folder, test_name, DEBUG_FILE)


def get_info_file():
    return os.path.join(output_folder, test_name, INFO_FILE)


def get_image_file(plot_name: str):
    # Save each figure separately using plot_name
    return os.path.join(output_folder, test_name, f"{test_name}_{plot_name}.png")


def main():
    debug_file = get_debug_file()
    info_file = get_info_file()

    # Plot and save Unsound plot
    plt.figure()
    unsound.plot(debug_file, test_name)
    image_path = get_image_file("unsound")
    plt.savefig(image_path)
    plt.close()
    print("Unsound plot saved at:", image_path)

    # Plot and save Profile plot
    plt.figure()
    profile.plot(debug_file)
    image_path = get_image_file("profile")
    plt.savefig(image_path)
    plt.close()
    print("Profile plot saved at:", image_path)

    # Plot and save Precision plot
    plt.figure()
    precision.plot(info_file)
    image_path = get_image_file("precision")
    plt.savefig(image_path)
    plt.close()
    print("Precision plot saved at:", image_path)

    # # Plot and save MCMC plot
    # plt.figure()
    # mcmc.plot(debug_file, "1_226_86", False)
    # image_path = get_image_file("mcmc")
    # plt.savefig(image_path)
    # plt.close()
    # print("MCMC plot saved at:", image_path)


main()
