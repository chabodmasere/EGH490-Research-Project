// vapp_analysis.cpp
// Purpose: Analyze 6x6 complex Vapp data (Re + i·Im), compute magnitude/phase,
//          center-4 averages, normalized magnitude, and phase deviation grids.
//
// Build (Windows / PowerShell):
//   g++ -O2 -std=c++17 vapp_analysis.cpp -o vapp_analysis.exe
//
// Run (Windows / PowerShell):
//   .\vapp_analysis.exe

#include <iostream>
#include <iomanip>
#include <cmath>
#include <complex>
#include <fstream>

int main() {
    constexpr int N = 6;
    const double RAD2DEG = 180.0 / std::acos(-1.0);

    std::ofstream outFile("vapp_analysis_output.txt");
    if (!outFile) {
        std::cerr << "Error: Could not create output file 'vapp_analysis_output.txt'.\n";
        return 1;
    }

    // Re[Vapp] (i = row 1..6, j = col 1..6)
    const double Re[N][N] = {
        {1.4306804942992, 1.5578194451661, 2.1900688904949, 1.6480174134865, 1.9642274168938, 1.2255279350535},
        {3.0535856389074, 4.1024130928465, 5.3176739858674, 4.7560391046071, 4.4568883051169, 2.8979241354045},
        {4.0155145086903, 5.9038670153139, 6.9997624474471, 6.8310145760952, 5.8737174719142, 4.1186668501635},
        {4.0919447574590, 5.8991211347727, 6.9134569903258, 7.0123716040461, 5.8456113378081, 3.9752391497389},
        {2.9157367925029, 4.4662918463924, 4.9382998974743, 5.3748797986801, 4.1220500573594, 3.0313798325779},
        {1.2417566637163, 1.9981187617230, 1.8056540605840, 2.3408194825198, 1.4303270226417, 1.4494986692941}
    };

    // Im[Vapp]
    const double Im[N][N] = {
        {-1.2154238411443, -2.2996391058387, -3.7298772507791, -3.4713106709322, -2.3812305924632, -1.1418836379064},
        {-1.9743629597035, -4.4002507636670, -6.2552735849317, -6.7797270745564, -4.0398089827427, -2.1609317611943},
        {-2.5433471044723, -5.2351480614382, -7.7989529044899, -8.2660449942037, -5.0214958504663, -2.6174743859838},
        {-2.7746599421165, -5.2284420535237, -8.6539805804671, -8.2396121540260, -5.6341608116956, -2.7236335369846},
        {-1.9995057080881, -3.7856949723058, -6.2936020413673, -5.8777243383082, -4.2092328652306, -1.9416434072191},
        {-1.1551362884020, -2.4326532260321, -3.4943215068759, -3.7575262169703, -2.4224560816959, -1.1965266421293}
    };

    // Derived grids
    double mag[N][N];
    double phaseDeg[N][N];

    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            mag[i][j]      = std::hypot(Re[i][j], Im[i][j]);          // sqrt(Re^2 + Im^2)
            phaseDeg[i][j] = std::atan2(Im[i][j], Re[i][j]) * RAD2DEG; // matches Excel ATAN2(imag, real)
        }
    }

    // Center-4 averages: indices (3,3),(3,4),(4,3),(4,4) -> zero-based (2,2),(2,3),(3,2),(3,3)
    double magCenter = (mag[2][2] + mag[2][3] + mag[3][2] + mag[3][3]) / 4.0;
    double phaseCenter = (phaseDeg[2][2] + phaseDeg[2][3] + phaseDeg[3][2] + phaseDeg[3][3]) / 4.0;

    auto printGrid = [&](const char* title, auto& g, const char* unit, int prec) {
        std::cout << "\n=== " << title << " ===\n";
        outFile  << "\n=== " << title << " ===\n";
        std::cout << "         ";
        outFile  << "         ";
        for (int j = 1; j <= N; ++j) {
            std::cout << std::setw(12) << ("j=" + std::to_string(j));
            outFile  << std::setw(12) << ("j=" + std::to_string(j));
        }
        std::cout << "\n";
        outFile  << "\n";
        for (int i = 0; i < N; ++i) {
            std::cout << "i=" << (i+1) << "  ";
            outFile  << "i=" << (i+1) << "  ";
            for (int j = 0; j < N; ++j) {
                std::cout << std::setw(11) << std::fixed << std::setprecision(prec) << g[i][j] << unit;
                outFile  << std::setw(11) << std::fixed << std::setprecision(prec) << g[i][j] << unit;
            }
            std::cout << "\n";
            outFile  << "\n";
        }
    };

    std::cout << std::fixed << std::setprecision(6);
    outFile  << std::fixed << std::setprecision(6);

    printGrid("Re[Vapp]", Re, "", 6);
    printGrid("Im[Vapp]", Im, "", 6);
    printGrid("|Vapp| (Magnitude)", mag, "", 6);
    printGrid("Phase Angle (deg)", phaseDeg, "°", 2);

    // Complex form printout
    std::cout << "\n=== Vapp = Re + i Im (Complex Form) ===\n";
    outFile  << "\n=== Vapp = Re + i Im (Complex Form) ===\n";
    for (int i = 0; i < N; ++i) {
        std::cout << "i=" << (i+1) << "  ";
        outFile  << "i=" << (i+1) << "  ";
        for (int j = 0; j < N; ++j) {
            char sign = (Im[i][j] >= 0) ? '+' : '-';
            std::cout << std::setw(8) << std::fixed << std::setprecision(3) << Re[i][j]
                      << " " << sign << " "
                      << std::setw(6) << std::fixed << std::setprecision(3) << std::fabs(Im[i][j])
                      << "i   ";
            outFile  << std::setw(8) << std::fixed << std::setprecision(3) << Re[i][j]
                     << " " << sign << " "
                     << std::setw(6) << std::fixed << std::setprecision(3) << std::fabs(Im[i][j])
                     << "i   ";
        }
        std::cout << "\n";
        outFile  << "\n";
    }

    // Center-4 summary
    std::cout << "\n=== Center 4 Averages ===\n";
    outFile  << "\n=== Center 4 Averages ===\n";
    std::cout << "  |Vapp|(3,3) = " << std::setprecision(6) << mag[2][2] << "\n";
    outFile  << "  |Vapp|(3,3) = " << std::setprecision(6) << mag[2][2] << "\n";
    std::cout << "  |Vapp|(3,4) = " << mag[2][3] << "\n";
    outFile  << "  |Vapp|(3,4) = " << mag[2][3] << "\n";
    std::cout << "  |Vapp|(4,3) = " << mag[3][2] << "\n";
    outFile  << "  |Vapp|(4,3) = " << mag[3][2] << "\n";
    std::cout << "  |Vapp|(4,4) = " << mag[3][3] << "\n";
    outFile  << "  |Vapp|(4,4) = " << mag[3][3] << "\n";
    std::cout << "  Average |Vapp| (center 4)  = " << magCenter   << "\n";
    outFile  << "  Average |Vapp| (center 4)  = " << magCenter   << "\n";
    std::cout << "  Average Phase (center 4)   = " << std::setprecision(4) << phaseCenter << "°\n";
    outFile  << "  Average Phase (center 4)   = " << std::setprecision(4) << phaseCenter << "°\n";

    // Normalized magnitude grid
    double normMag[N][N];
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            normMag[i][j] = mag[i][j] / magCenter;
    printGrid("|Vapp(m,n)| / |Vcenter| (Normalized)", normMag, "", 4);

    // Phase deviation grid
    double phaseDev[N][N];
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            phaseDev[i][j] = phaseDeg[i][j] - phaseCenter;
    printGrid("Phase Deviation from Center (deg)", phaseDev, "°", 2);

    // Quick sanity checks
    std::cout << "\n=== Sanity Checks ===\n";
    outFile  << "\n=== Sanity Checks ===\n";
    double sumDevCenter = phaseDev[2][2] + phaseDev[2][3] + phaseDev[3][2] + phaseDev[3][3];
    double avgNormCenter = (normMag[2][2] + normMag[2][3] + normMag[3][2] + normMag[3][3]) / 4.0;
    std::cout << "  Sum of center-4 phase deviations (should be ~0): "
              << std::scientific << std::setprecision(3) << sumDevCenter << "\n";
    outFile  << "  Sum of center-4 phase deviations (should be ~0): "
             << std::scientific << std::setprecision(3) << sumDevCenter << "\n";
    std::cout << "  Average of center-4 normalized mag (should be 1): "
              << std::fixed << std::setprecision(6) << avgNormCenter << "\n";
    outFile  << "  Average of center-4 normalized mag (should be 1): "
             << std::fixed << std::setprecision(6) << avgNormCenter << "\n";

    return 0;
}