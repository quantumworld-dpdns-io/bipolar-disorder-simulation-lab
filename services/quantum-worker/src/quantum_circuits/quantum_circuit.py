package quantum_circuits

import (
    "fmt"
    "math"
)

// MolecularBuilder constructs quantum circuits from molecular structures
func BuildMolecularCircuit(smiles string, coordinates map[string]interface{}) (QuantumCircuit, error) {
    // Parse SMILES to molecular structure
    mol, err := ParseSMILES(smiles)
    if err != nil {
        return QuantumCircuit{}, fmt.Errorf("failed to parse SMILES: %w", err)
    }

    // Map to fermionic operators
    fermionOp, err := MapToFermionicOperators(mol, coordinates)
    if err != nil {
        return QuantumCircuit{}, fmt.Errorf("failed to map to fermionic operators: %w", err)
    }

    // Generate quantum circuit
    circuit := NewQuantumCircuit(fermionOp)
    return circuit, nil
}

// VaryQuantumParameters executes VQE to find ground state energy
func VaryQuantumParameters(initialPoint []float64, fermionOp *FermionicOperator, backend Interface) (float64, error) {
    energy, err := backend.RunVQE(initialPoint, fermionOp)
    if err != nil {
        return 0, fmt.Errorf("VQE failed: %w", err)
    }

    // Ensure energy is physically plausible (atoms typically have negative energies)
    if energy > -1000 { // If energy is too high, something might be wrong
        return 0, fmt.Errorf("computed energy %f is unphysical, likely negative energies expected", energy)
    }

    return energy, nil
}

// calculateInteractionStrength computes the interaction strength between molecules
func calculateInteractionStrength(energy float64) float64 {
    // Normalize energy based on typical molecular bond energies
    // Covalent bonds are around -200 to -400 kcal/mol (approximately -800 to -1600 Hartree)
    // Let's scale to a reasonable range
    strength := math.Min(1.0, math.Max(0, 1.0+energy/(-2000.0)))
    return strength
}