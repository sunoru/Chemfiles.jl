@testset "Topology type" begin
    topology = Topology()

    @test size(topology) == 0
    @test size(topology) == 0

    # Creating some H2O2
    push!(topology, Atom("H"))
    push!(topology, Atom("O"))
    push!(topology, Atom("O"))
    push!(topology, Atom("H"))
    @test size(topology) == 4

    @test nbonds(topology) == 0
    @test nangles(topology) == 0
    @test ndihedrals(topology) == 0

    add_bond!(topology, 0, 1)
    add_bond!(topology, 1, 2)
    add_bond!(topology, 2, 3)

    @test nbonds(topology) == 3
    @test nangles(topology) == 2
    @test ndihedrals(topology) == 1

    @test isbond(topology, 0, 1) == true
    @test isbond(topology, 0, 3) == false
    @test isangle(topology, 0, 1, 2) == true
    @test isangle(topology, 0, 1, 3) == false
    @test isdihedral(topology, 0, 1, 2, 3) == true
    @test isdihedral(topology, 0, 1, 3, 2) == false

    top_bonds = reshape(UInt64[0, 1,   1, 2,   2, 3], (2, 3))

    @test bonds(topology) == top_bonds
    @test angles(topology) == reshape(UInt64[0, 1, 2,   1, 2, 3,], (3, 2))
    @test dihedrals(topology) == reshape(UInt64[0, 1, 2, 3], (4,1))

    remove_bond!(topology, 2, 3)
    @test nbonds(topology) == 2
    @test nangles(topology) == 1
    @test ndihedrals(topology) == 0

    remove!(topology, 3)
    @test size(topology) == 3

    resize!(topology, 42)
    @test size(topology) == 42

    copy = deepcopy(topology)
    @test size(copy) == 42

    resize!(copy, 25)
    @test size(copy) == 25
    @test size(topology) == 42

    @testset "Residues" begin
        topology = Topology()
        for i = 1:10
            push!(topology, Atom("X"))
        end

        for atoms in [[2,3,6], [0,1,9], [4,5,8]]
            residue = Residue("X")
            for i in atoms
                add_atom!(residue, i)
            end
            add_residue!(topology, residue)
        end

        @test count_residues(topology) == 3

        first = residue_for_atom(topology, 2)
        second = residue_for_atom(topology, 0)

        @test residue_for_atom(topology, 7) == nothing

        @test first != nothing
        @test second != nothing
        @test_throws ChemfilesError Residue(topology, 4)

        @test are_linked(topology, first, second) == false

        add_bond!(topology, 6, 9)
        @test are_linked(topology, first, second) == true
    end
end
