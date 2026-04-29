#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <cstdlib>
#include <iomanip>

struct SweepPoint {
    double offset_mm{};
    double Gself{};
    double Bself{};
};

struct SlotDesign {
    int slot{};
    double z_mm{};
    double amplitude{};
    double target_G{};
    double offset_mm{};
    double estimated_B{};
};

std::vector<SlotDesign> buildSlotArray(const std::vector<SweepPoint>& sweep) {
    std::vector<SlotDesign> slots;
    slots.reserve(sweep.size());

    for (std::size_t i = 0; i < sweep.size(); ++i) {
        SlotDesign s;
        s.slot = static_cast<int>(i + 1);
        s.z_mm = 0.0;        // placeholder until design formula is provided
        s.amplitude = 0.0;   // placeholder until design formula is provided
        s.target_G = sweep[i].Gself;
        s.offset_mm = sweep[i].offset_mm;
        s.estimated_B = sweep[i].Bself;
        slots.push_back(s);
    }

    return slots;
}

std::vector<SweepPoint> readSweepCSV(const std::string& filename) {
    std::vector<SweepPoint> data;
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "Error: could not open CSV file: " << filename << '\n';
        return data;
    }

    std::string line;

    // Skip header row
    if (!std::getline(file, line)) {
        std::cerr << "Error: CSV appears empty: " << filename << '\n';
        return data;
    }

    while (std::getline(file, line)) {
        if (line.empty()) continue;

        std::stringstream ss(line);
        std::string c1, c2, c3;

        if (!std::getline(ss, c1, ',')) continue;
        if (!std::getline(ss, c2, ',')) continue;
        if (!std::getline(ss, c3, ',')) continue;

        SweepPoint p;
        p.offset_mm = std::atof(c1.c_str());
        p.Gself     = std::atof(c2.c_str());
        p.Bself     = std::atof(c3.c_str());
        data.push_back(p);
    }

    return data;
}

void print2x3Graph(const std::vector<SlotDesign>& slots) {
    const int rows = 2;
    const int cols = 3;
    const int total = rows * cols;

    std::cout << "\n2 x 3 SLOT WAVEGUIDE OVERVIEW\n";
    std::cout << "Legend per slot: [S#:off=<offset_mm>, G=<target_G>, B=<estimated_B>]\n\n";

    std::size_t idx = 0;
    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            std::cout << "+------------------------------+";
        }
        std::cout << '\n';

        for (int c = 0; c < cols; ++c) {
            if (idx < slots.size() && idx < static_cast<std::size_t>(total)) {
                const SlotDesign& s = slots[idx];
                std::ostringstream label;
                label << "S" << s.slot
                      << ":off=" << std::fixed << std::setprecision(3) << s.offset_mm
                      << ",G=" << std::setprecision(3) << s.target_G
                      << ",B=" << std::setprecision(3) << s.estimated_B;
                std::string txt = label.str();
                if (txt.size() > 28) txt = txt.substr(0, 28);
                std::cout << "| " << std::left << std::setw(28) << txt << " |";
            } else {
                std::cout << "| " << std::left << std::setw(28) << "(empty)" << " |";
            }
            ++idx;
        }
        std::cout << '\n';
    }

    for (int c = 0; c < cols; ++c) {
        std::cout << "+------------------------------+";
    }
    std::cout << "\n\nPropagation direction:  --> z\n";
}

int main() {
    // Use relative path from repo root
    const std::string csvPath = "Array_Analysis/OPEN_SLOT_CAVITY (SIM3).csv";
    std::vector<SweepPoint> sweepData = readSweepCSV(csvPath);
    std::vector<SlotDesign> slotArray = buildSlotArray(sweepData);

    std::cout << "Loaded " << sweepData.size() << " rows from " << csvPath << '\n';
    std::cout << "Created slot array with " << slotArray.size() << " slots\n";

    if (!slotArray.empty()) {
        const SlotDesign& s = slotArray.front();
        std::cout << "First slot => slot: " << s.slot
                  << ", offset_mm: " << s.offset_mm
                  << ", target_G: " << s.target_G
                  << ", estimated_B: " << s.estimated_B
                  << ", z_mm: " << s.z_mm
                  << ", amplitude: " << s.amplitude << '\n';
    }

    print2x3Graph(slotArray);

    return 0;
}
