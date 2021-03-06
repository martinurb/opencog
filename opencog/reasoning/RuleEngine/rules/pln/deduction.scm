; =============================================================================
; Deduction Rule
;
; AND(Inheritance A B, Inheritance B C) entails Inheritance A C
; -----------------------------------------------------------------------------

(define pln-rule-deduction
    (BindLink
        (VariableList
            (VariableNode "$A")
            (VariableNode "$B")
            (VariableNode "$C"))
        (ImplicationLink
            (AndLink
                (InheritanceLink
                    (VariableNode "$A")
                    (VariableNode "$B"))
                (InheritanceLink
                    (VariableNode "$B")
                    (VariableNode "$C")))
            (ExecutionOutputLink
                (GroundedSchemaNode "scm: pln-formula-simple-deduction")
                (ListLink
                    (InheritanceLink
                        (VariableNode "$A")
                        (VariableNode "$B"))
                    (InheritanceLink
                        (VariableNode "$B")
                        (VariableNode "$C"))
                    (InheritanceLink
                        (VariableNode "$A")
                        (VariableNode "$C")))))))

; -----------------------------------------------------------------------------
; Deduction Formula
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; Side-effect: TruthValue of AC may be updated
; -----------------------------------------------------------------------------
(define (pln-formula-simple-deduction AB BC AC)
    (cog-set-tv!
        AC
        (pln-formula-simple-deduction-side-effect-free
            AB
            BC
            AC)))

; -----------------------------------------------------------------------------
; This version has no side effects and simply returns a TruthValue
;
; AC.s = ((AB.s * BC.s) + ((1 - AB.s) * (C.s - (B.s * BC.s)))) / (1 - B.s)
;
; AC.c = min(AB.TV.c, BC.TV.c)
; -----------------------------------------------------------------------------

(define (pln-formula-simple-deduction-side-effect-free AB BC AC)
    (let
        ((sB (cog-stv-strength (gdr AB)))
         (sC (cog-stv-strength (gdr BC))))
            (stv
                (if (approx-eq?
                        0
                        (-
                            1
                            sB))
                    0 ; Set Strength to 0 if sNotB equals 0 to avoid
                      ; division by zero
                    (+                         ; Strength
                        (* (cog-stv-strength AB) (cog-stv-strength BC))
                        (/
                            (*
                                (-
                                    1
                                    (cog-stv-strength AB))
                                (-
                                    sC
                                    (*
                                        sB
                                        (cog-stv-strength BC))))
                            (-
                                1
                                sB))))
                (min
                    (cog-stv-confidence AB)
                    (cog-stv-confidence BC))))) ; Confidence

; =============================================================================
