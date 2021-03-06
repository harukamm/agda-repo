open import Relation.Binary.PropositionalEquality
open ≡-Reasoning
open import Data.Product hiding (<_,_>; ,_)

-- Basics
--- Categories

module category
    (obC : Set)
    (morC : obC → obC → Set)
    (_∘_ : {A B C : obC} → morC B C → morC A B → morC A C)
    (∘-assoc : {A B C D : obC} →
        {f : morC C D} → {g : morC B C} → {h : morC A B} →
        f ∘ (g ∘ h) ≡ (f ∘ g) ∘ h)
    (id : (A : obC) → morC A A)
    (idL : {A B : obC} → {f : morC A B} → id B ∘ f ≡ f)
    (idR : {A B : obC} → {f : morC A B} → f ∘ id A ≡ f)
  where

dom : {A B : obC} → morC A B → obC
dom {A} _ = A

cod : {A B : obC} → morC A B → obC
cod {B = B} _ = B

record inverse {A B : obC} (f : morC A B) (g : morC B A) : Set where
  field
    invL : g ∘ f ≡ id A
    invR : f ∘ g ≡ id B

inverse-unique : {A B : obC} → {f : morC A B} → {g h : morC B A} →
        inverse f g → inverse f h → g ≡ h
inverse-unique {A} {B} {f} {g} {h} inv-g inv-h = begin
    g
  ≡⟨ sym idR ⟩
    g ∘ id B
  ≡⟨ cong (_∘_ g) (sym (inverse.invR inv-h)) ⟩
    g ∘ (f ∘ h)
  ≡⟨ ∘-assoc ⟩
    (g ∘ f) ∘ h
  ≡⟨ cong (λ x → x ∘ h) (inverse.invL inv-g) ⟩
    id A ∘ h
  ≡⟨ idL ⟩
    h
  ∎

-- 定理 1.4.4 equivalence relation
record _≅_ (A : obC) (B : obC) : Set where
  field
    f : morC A B
    g : morC B A
    proof : inverse f g

record iso {A B : obC} (f : morC A B) : Set where
  field
    g : morC B A        -- g が存在し
    proof : inverse f g -- それは f の inverse である

isof→A≅B : {A B : obC} → {f : morC A B} → iso f → A ≅ B
isof→A≅B {A} {B} {f} iso-f =
  record { f = f
         ; g = iso.g iso-f
         ; proof = iso.proof iso-f
         }
A≅B→isof : {A B : obC} → (p : A ≅ B) → iso (_≅_.f p)
A≅B→isof {A} {B} p =
  record { g = _≅_.g p
         ; proof = _≅_.proof p
         }

-- reflection
iso-refl : {A : obC} → A ≅ A
iso-refl {A} =
  record { g = id A
         ; proof = record { invL = p1
                          ; invR = p1
                          }
         }
    where p1 : id A ∘ id A ≡ id A
          p1 = begin
            id A ∘ id A
           ≡⟨ idL ⟩
            id A
           ∎

-- symmetric
iso-sym : {A B : obC} → A ≅ B → B ≅ A
iso-sym {A} {B} iso-ab =
  record { g = _≅_.f iso-ab
         ; proof = record { invL = f∘g-idB
                          ; invR = g∘f-idA
                          }
         }
    where g = _≅_.g iso-ab
          inv-fg = _≅_.proof iso-ab
          f∘g-idB = inverse.invR inv-fg
          g∘f-idA = inverse.invL inv-fg

-- transitive
iso-trans : {A B C : obC} → A ≅ B → B ≅ C → A ≅ C
iso-trans {A} {B} {C} iso-ab iso-bc = 
  record { f = h ∘ f
         ; g = g ∘ k
         ; proof = record { invL = [g∘k]∘[h∘f]-idA
                          ; invR = [h∘f]∘[g∘k]-idC
                          }
         }
    where f = _≅_.f iso-ab
          g = _≅_.g iso-ab
          h = _≅_.f iso-bc
          k = _≅_.g iso-bc
          pf-iso-ab = _≅_.proof iso-ab
          pf-iso-bc = _≅_.proof iso-bc
          invL-AB = inverse.invL pf-iso-ab
          invR-AB = inverse.invR pf-iso-ab
          invL-BC = inverse.invL pf-iso-bc
          invR-BC = inverse.invR pf-iso-bc
          [h∘f]∘[g∘k]-idC : (h ∘ f) ∘ (g ∘ k) ≡ id C
          [h∘f]∘[g∘k]-idC = begin
              (h ∘ f) ∘ (g ∘ k)
            ≡⟨ ∘-assoc ⟩
              ((h ∘ f) ∘ g) ∘ k
            ≡⟨ cong (λ x → x ∘ k) (sym ∘-assoc) ⟩
              (h ∘ (f ∘ g)) ∘ k
            ≡⟨ cong (λ x → (h ∘ x) ∘ k) invR-AB ⟩
              (h ∘ id B) ∘ k
            ≡⟨ cong (λ x → x ∘ k) idR ⟩
              h ∘ k
            ≡⟨ invR-BC ⟩
              id C
            ∎
          [g∘k]∘[h∘f]-idA : (g ∘ k) ∘ (h ∘ f) ≡ id A
          [g∘k]∘[h∘f]-idA = begin
              (g ∘ k) ∘ (h ∘ f)
            ≡⟨ ∘-assoc ⟩
              ((g ∘ k) ∘ h) ∘ f
            ≡⟨ cong (λ x → x ∘ f) (sym ∘-assoc) ⟩
              (g ∘ (k ∘ h)) ∘ f
            ≡⟨ cong (λ x → (g ∘ x) ∘ f) invL-BC ⟩
              (g ∘ id B) ∘ f
            ≡⟨ cong (λ x → x ∘ f) idR ⟩
              g ∘ f
            ≡⟨ invL-AB ⟩
              id A
            ∎

-- 問題 1.4.5
inverse-left-right : {A B : obC} → {f : morC A B} → {g h : morC B A} → h ∘ f ≡ id A → f ∘ g ≡ id B → g ≡ h
inverse-left-right {A} {B} {f} {g} {h} inv-l inv-r = begin
    g
  ≡⟨ sym idL ⟩
    id A ∘ g
  ≡⟨ cong (λ x → x ∘ g) (sym inv-l) ⟩
    (h ∘ f) ∘ g
  ≡⟨ sym ∘-assoc ⟩
    h ∘ (f ∘ g)
  ≡⟨ cong (_∘_ h) inv-r ⟩
    h ∘ id B
  ≡⟨ idR ⟩
    h
  ∎

--- Monics and Epics

monic : {A B : obC} → (f : morC A B) → Set
monic {A} {B} f = {T : obC} → {g h : morC T A} → f ∘ g ≡ f ∘ h → g ≡ h

monic-composite : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        monic f → monic g → monic (g ∘ f)
monic-composite {f = f} {g = g} monic-f monic-g =
  λ {T} {g′} {h′} eq →
    let eq′ : g ∘ (f ∘ g′) ≡ g ∘ (f ∘ h′)
        eq′ = begin
            g ∘ (f ∘ g′)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ g′
          ≡⟨ eq ⟩
            (g ∘ f) ∘ h′
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ h′)
          ∎ in
    monic-f (monic-g eq′)

composite-monic : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        monic (g ∘ f) → monic f
composite-monic {f = f} {g = g} monic-g∘f =
  λ {T} {g′} {h′} eq →
    let eq′ : (g ∘ f) ∘ g′ ≡ (g ∘ f) ∘ h′
        eq′ = begin
            (g ∘ f) ∘ g′
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ g′)
          ≡⟨ cong (λ x → g ∘ x) eq ⟩
            g ∘ (f ∘ h′)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ h′
          ∎ in
    monic-g∘f eq′

epic : {A B : obC} → (f : morC A B) → Set
epic {A} {B} f = {T : obC} → {g h : morC B T} → g ∘ f ≡ h ∘ f → g ≡ h

epic-composite : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        epic f → epic g → epic (g ∘ f)
epic-composite {f = f} {g = g} epic-f epic-g =
  λ {T} {g′} {h′} eq →
    let eq′ : (g′ ∘ g) ∘ f ≡ (h′ ∘ g) ∘ f
        eq′ = begin
            (g′ ∘ g) ∘ f
          ≡⟨ sym ∘-assoc ⟩
            g′ ∘ (g ∘ f)
          ≡⟨ eq ⟩
            h′ ∘ (g ∘ f)
          ≡⟨ ∘-assoc ⟩
            (h′ ∘ g) ∘ f
          ∎ in
    (epic-g (epic-f eq′))

record split-epic {A B : obC} (f : morC A B) : Set where
  field
    g : morC B A
    invR : f ∘ g ≡ id B

-- theorem 1.5.7
split-epic→epic : {A B : obC} → {f : morC A B} → split-epic f → epic f
split-epic→epic {B = B} {f = f} split-epic-f =
  λ {T} {g′} {h′} eq → begin
    g′
  ≡⟨ sym idR ⟩
    g′ ∘ id B
  ≡⟨ cong (λ x → g′ ∘ x) (sym invR) ⟩
    g′ ∘ (f ∘ g)
  ≡⟨ ∘-assoc ⟩
    (g′ ∘ f) ∘ g
  ≡⟨ cong (λ x → x ∘ g) eq ⟩
    (h′ ∘ f) ∘ g
  ≡⟨ sym ∘-assoc ⟩
    h′ ∘ (f ∘ g)
  ≡⟨ cong (λ x → h′ ∘ x) invR ⟩
    h′ ∘ id B
  ≡⟨ idR ⟩
    h′
  ∎
  where g = split-epic.g split-epic-f
        invR = split-epic.invR split-epic-f

-- theorem 1.5.8
monic-and-split-epic→iso : {A B : obC} → {f : morC A B} → monic f → split-epic f → iso f
monic-and-split-epic→iso {A} {B} {f} monic-f split-epic-f =
  record { g = g
         ; proof = record { invL = monic-f eq
                          ; invR = invR
                          }
         }
    where g = split-epic.g split-epic-f
          invR = split-epic.invR split-epic-f
          eq : f ∘ (g ∘ f) ≡ f ∘ id A
          eq = begin
             f ∘ (g ∘ f)
            ≡⟨ ∘-assoc ⟩
             (f ∘ g) ∘ f
            ≡⟨ cong (λ x → x ∘ f) invR ⟩
             id B ∘ f
            ≡⟨ idL ⟩
             f
            ≡⟨ sym idR ⟩
             f ∘ id A
            ∎

iso→monic : {A B : obC} → {f : morC A B} → iso f → monic f
iso→monic {A} {B} {f} iso-f {T} {h} {k} eq = eq′
  where g = iso.g iso-f
        invL : g ∘ f ≡ id A
        invL = inverse.invL (iso.proof iso-f)
        invR : f ∘ g ≡ id B
        invR = inverse.invR (iso.proof iso-f)
        eq′ : h ≡ k
        eq′ = begin
            h
          ≡⟨ sym idL ⟩
            id A ∘ h
          ≡⟨ cong (λ x → x ∘ h) (sym invL) ⟩
            (g ∘ f) ∘ h
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ h)
          ≡⟨ cong (_∘_ g) eq ⟩
            g ∘ (f ∘ k)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ k
          ≡⟨ cong (λ x → x ∘ k) invL ⟩
            id A ∘ k
          ≡⟨ idL ⟩
            k
          ∎

iso→split-epic : {A B : obC} → {f : morC A B} → iso f → split-epic f
iso→split-epic {A} {B} {f} iso-f = record { g = g ; invR = invR }
  where g = iso.g iso-f
        invR : f ∘ g ≡ id B
        invR = inverse.invR (iso.proof iso-f)

iso→monic-and-split-epic : {A B : obC} → {f : morC A B} → iso f → monic f × split-epic f
iso→monic-and-split-epic {A} {B} {f} iso-f = monic-f , split-epic-f
  where monic-f : monic f
        monic-f = iso→monic iso-f
        split-epic-f : split-epic f
        split-epic-f =
          record { g = iso.g iso-f
                 ; invR = inverse.invR (iso.proof iso-f)
                 }

≡-trans : ∀{l}{A : Set l} -> {x y z : A} -> x ≡ y -> y ≡ z -> x ≡ z
≡-trans {_}{_} {x} {y} {z} x≡y y≡z = begin
          x
        ≡⟨ x≡y ⟩
          y
        ≡⟨ y≡z ⟩
          z
        ∎

-- Limits and Their Duals
--- Terminal and Initial Objects
record exist-unique (A : Set) : Set where
  field
    ! : A
    unique : (o : A) → o ≡ !

record exist-unique-P {A : Set} (P : A → Set) : Set where
  field
    ! : A
    proof : P !
    unique : (o : A) → P o → o ≡ !

record terminal (one : obC) : Set where
  field
    proof : {A : obC} → exist-unique (morC A one)

record initial (⊘ : obC) : Set where
  field
    proof : {A : obC} → exist-unique (morC ⊘ A)

record zero (z : obC) : Set where
  field
    t : terminal z
    i : initial z

unique→id : {A B : obC} → {f : morC A B} → {g : morC B A} →
            exist-unique (morC A A) → g ∘ f ≡ id A
unique→id {A} {B} {f} {g} uni-A→A = ≡-trans g∘f≡A→A (sym idA≡A→A)
    where A→A : morC A A
          A→A = exist-unique.! uni-A→A
          idA≡A→A : id A ≡ A→A
          idA≡A→A = exist-unique.unique uni-A→A (id A)
          g∘f≡A→A : g ∘ f ≡ A→A
          g∘f≡A→A = exist-unique.unique uni-A→A (g ∘ f)

-- Theorem 2.1.2
terminal-iso : {one one′ : obC} → terminal one → terminal one′ → one ≅ one′
terminal-iso {one} {one′} t t′ =
  record { f = !1′
         ; g = !1
         ; proof = record { invR = unique→id {one′} {one} { !1} { !1′} 1′→1′-unique
                          ; invL = unique→id {one} {one′} { !1′} { !1} 1→1-unique
                          }
         }
    where 1′→1-unique : exist-unique (morC one′ one)
          1′→1-unique = terminal.proof t {one′}
          1→1′-unique : exist-unique (morC one one′)
          1→1′-unique = terminal.proof t′ {one}
          !1 : morC one′ one            -- a unique morC one′ one
          !1 = exist-unique.! 1′→1-unique
          !1′ : morC one one′           -- a unique morC one one′
          !1′ = exist-unique.! 1→1′-unique
          1→1-unique : exist-unique (morC one one)
          1→1-unique = terminal.proof t {one}
          1′→1′-unique : exist-unique (morC one′ one′)
          1′→1′-unique = terminal.proof t′ {one′}

-- Theorem 2.1.5
initial-iso : {⊘ ⊘′ : obC} → initial ⊘ → initial ⊘′ → ⊘ ≅ ⊘′
initial-iso {⊘} {⊘′} i i′ =
  record { f = !⊘′
         ; g = !⊘
         ; proof = record { invR = !⊘′∘!⊘≡id⊘′
                          ; invL = !⊘∘!⊘′≡id⊘
                          }
         }
    where ⊘→⊘′-unique : exist-unique (morC ⊘ ⊘′)
          ⊘→⊘′-unique = initial.proof i {⊘′}
          !⊘′ : morC ⊘ ⊘′
          !⊘′ = exist-unique.! (⊘→⊘′-unique)
          ⊘′→⊘-unique : exist-unique (morC ⊘′ ⊘)
          ⊘′→⊘-unique = initial.proof i′ {⊘}
          !⊘ : morC ⊘′ ⊘
          !⊘ = exist-unique.! (⊘′→⊘-unique)
          ⊘→⊘-unique : exist-unique (morC ⊘ ⊘)
          ⊘→⊘-unique = initial.proof i {⊘}
          !⊘∘!⊘′≡id⊘ : !⊘ ∘ !⊘′ ≡ id ⊘
          !⊘∘!⊘′≡id⊘ = unique→id {⊘} {⊘′} { !⊘′} { !⊘} ⊘→⊘-unique
          ⊘′→⊘′-unique : exist-unique (morC ⊘′ ⊘′)
          ⊘′→⊘′-unique = initial.proof i′ {⊘′}
          !⊘′∘!⊘≡id⊘′ : !⊘′ ∘ !⊘ ≡ id ⊘′
          !⊘′∘!⊘≡id⊘′ = unique→id {⊘′} {⊘} { !⊘} { !⊘′} ⊘′→⊘′-unique

-- Theorem 2.1.6
split-epic-A→⊘ : {A ⊘ : obC} → initial ⊘ → {f : morC A ⊘} → split-epic f
split-epic-A→⊘ {A} {⊘} ini⊘ {f} =
  record { g = !A
         ; invR = pf
         }
    where ⊘→A-unique : exist-unique (morC ⊘ A)
          ⊘→A-unique = initial.proof ini⊘ {A}
          !A : morC ⊘ A
          !A = exist-unique.! (⊘→A-unique)
          ⊘→⊘-unique : exist-unique (morC ⊘ ⊘)
          ⊘→⊘-unique = initial.proof ini⊘ {⊘}
          pf : f ∘ !A ≡ id ⊘
          pf = unique→id {⊘} {A} { !A} {f} ⊘→⊘-unique

-- exercise 2.1.7
1→B-monic : {one B : obC} → terminal one → {k : morC one B} → monic k
1→B-monic {one} {B} t {k} {T} {g} {h} eq = begin
          g
         ≡⟨ g≡m ⟩
          m
         ≡⟨ sym h≡m ⟩
          h
         ∎
  where pf : exist-unique (morC T one)
        pf = terminal.proof t {T}
        m = exist-unique.! pf
        g≡m = exist-unique.unique pf g
        h≡m = exist-unique.unique pf h
        
-- exercise 2.1.8
{-
ter-ini-zero : {⊘ one : obC} → initial ⊘ → terminal one → morC one ⊘ → zero ⊘ × zero one
ter-ini-zero {⊘} {one} ini⊘ ter1 f = zero⊘ , zero1
  where p1 : exist-unique (morC ⊘ one)
        p1 = terminal.proof ter1 {⊘}
        p2 : exist-unique (morC ⊘ one)
        p2 = initial.proof ini⊘ {one}
        ⊘→1 : morC ⊘ one
        ⊘→1 = exist-unique.! p1
        pf1 : {A : obC} → exist-unique (morC one A)
        pf1 {A} =
          record { ! = ⊘→A ∘ f
                 ; unique = λ m → {!!}
                 }
          where ⊘→A-unique : exist-unique (morC ⊘ A)
                ⊘→A-unique = initial.proof ini⊘ {A}
                ⊘→A : morC ⊘ A
                ⊘→A = exist-unique.! ⊘→A-unique
        ini1 : initial one
        ini1 = record { proof = pf1 }
        pf2 : {A : obC} → exist-unique (morC A ⊘)
        pf2 {A} =
          record { ! = f ∘ A→1
                 ; unique = λ m → {!!}
                 }
           where A→1-unique : exist-unique (morC A one)
                 A→1-unique = terminal.proof ter1 {A}
                 A→1 : morC A one
                 A→1 = exist-unique.! A→1-unique
        ter⊘ : terminal ⊘
        ter⊘ = record { proof = pf2 }
        zero⊘ : zero ⊘
        zero⊘ = record { t = ter⊘ ; i = ini⊘ }
        zero1 : zero one
        zero1 = record { t = ter1 ; i = ini1 }
-}

record _X_ (A B : obC) : Set where
  field
    obj : obC
    π₁ : morC obj A
    π₂ : morC obj B
    proof : {C : obC} → {f : morC C A} → {g : morC C B} →
            exist-unique-P (λ m → π₁ ∘ m ≡ f × π₂ ∘ m ≡ g)

bproduct-refl-id : {A B : obC} → (AxB : A X B) →
                   {h : morC (_X_.obj AxB) (_X_.obj AxB)} →
                   (_X_.π₁ AxB) ∘ h ≡ (_X_.π₁ AxB) × (_X_.π₂ AxB) ∘ h ≡ (_X_.π₂ AxB) →
                   h ≡ id (_X_.obj AxB)
bproduct-refl-id {A}{B} AxB {h} eqs = ≡-trans h≡! (sym id≡!)
  where obj = _X_.obj AxB
        π₁ = _X_.π₁ AxB
        π₂ = _X_.π₂ AxB
        eu : exist-unique-P {morC obj obj} (λ m → π₁ ∘ m ≡ π₁ × π₂ ∘ m ≡ π₂)
        eu = _X_.proof AxB
        ! = exist-unique-P.! eu
        id≡! : id obj ≡ !
        id≡! = exist-unique-P.unique eu (id obj) (idR , idR)
        h≡! : h ≡ !
        h≡! = exist-unique-P.unique eu h eqs

-- Theorem 2.2.2
{- For any objects A and B, a binary product of A and B is unique up isomorphism if it exists. -}
AxB-unique : {A : obC} → {B : obC} → (AXB : A X B) → (AXB′ : A X B) → _X_.obj AXB ≅ _X_.obj AXB′
AxB-unique {A} {B} AxB AxB′ =
  record { f = f
         ; g = g
         ; proof = record { invR = f∘g≡idP′
                          ; invL = g∘f≡idP
                          }
         }
  where P : obC
        P = _X_.obj AxB
        P′ : obC
        P′ = _X_.obj AxB′
        π₁p : morC P A
        π₁p = _X_.π₁ AxB
        π₂p : morC P B
        π₂p = _X_.π₂ AxB
        π₁p′ : morC P′ A
        π₁p′ = _X_.π₁ AxB′
        π₂p′ : morC P′ B
        π₂p′ = _X_.π₂ AxB′
        P→P′-unique : exist-unique-P (λ m → π₁p′ ∘ m ≡ π₁p × π₂p′ ∘ m ≡ π₂p)
        P→P′-unique = _X_.proof AxB′ {P} {π₁p} {π₂p}
        f : morC P P′
        f = exist-unique-P.! P→P′-unique
        P′→P-unique : exist-unique-P (λ m → π₁p ∘ m ≡ π₁p′ × π₂p ∘ m ≡ π₂p′)
        P′→P-unique = _X_.proof AxB {P′} {π₁p′} {π₂p′}
        g : morC P′ P
        g = exist-unique-P.! P′→P-unique
        eq1 : π₁p ∘ (g ∘ f) ≡ π₁p × π₂p ∘ (g ∘ f) ≡ π₂p
        eq1 = (begin
                π₁p ∘ (g ∘ f)
              ≡⟨ ∘-assoc ⟩
                (π₁p ∘ g) ∘ f
              ≡⟨ cong (λ e → e ∘ f) (proj₁ (exist-unique-P.proof P′→P-unique)) ⟩ 
                π₁p′ ∘ f
              ≡⟨ proj₁ (exist-unique-P.proof P→P′-unique) ⟩
                π₁p
              ∎) , (begin
                π₂p ∘ (g ∘ f)
              ≡⟨ ∘-assoc ⟩
                (π₂p ∘ g) ∘ f
              ≡⟨ cong (λ e → e ∘ f) (proj₂ (exist-unique-P.proof P′→P-unique)) ⟩
                π₂p′ ∘ f
              ≡⟨ proj₂ (exist-unique-P.proof P→P′-unique) ⟩
                π₂p
              ∎)
        eq2 : π₁p′ ∘ (f ∘ g) ≡ π₁p′ × π₂p′ ∘ (f ∘ g) ≡ π₂p′
        eq2 = (begin
                π₁p′ ∘ (f ∘ g)
              ≡⟨ ∘-assoc ⟩
                (π₁p′ ∘ f) ∘ g
              ≡⟨ cong (λ e → e ∘ g) (proj₁ (exist-unique-P.proof P→P′-unique)) ⟩
                π₁p ∘ g
              ≡⟨ proj₁ (exist-unique-P.proof P′→P-unique) ⟩
                π₁p′
              ∎) , (begin
                π₂p′ ∘ (f ∘ g)
              ≡⟨ ∘-assoc ⟩
                (π₂p′ ∘ f) ∘ g
              ≡⟨ cong (λ e → e ∘ g) (proj₂ (exist-unique-P.proof P→P′-unique)) ⟩
                π₂p ∘ g
              ≡⟨ proj₂ (exist-unique-P.proof P′→P-unique) ⟩
                π₂p′
              ∎)
        g∘f≡idP : g ∘ f ≡ id P
        g∘f≡idP = bproduct-refl-id AxB eq1
        f∘g≡idP′ : f ∘ g ≡ id P′
        f∘g≡idP′ = bproduct-refl-id AxB′ eq2

-- Exercise 2.2.3.
{- Show that product constructions are associative: for any objects A, B, C,
   A X (B X C) ≅ (A X B) X C -}

x-assoc : {A B C : obC} →
          {BxC : B X C} → {Ax[BxC] : A X (_X_.obj BxC)} →
          {AxB : A X B} → {[AxB]xC : (_X_.obj AxB) X C} → _X_.obj Ax[BxC] ≅ _X_.obj [AxB]xC
x-assoc {A}{B}{C} {BxC} {Ax[BxC]} {AxB} {[AxB]xC} =
  record { f = f
         ; g = g
         ; proof = record { invR = bproduct-refl-id [AxB]xC eq1
                          ; invL = bproduct-refl-id Ax[BxC] eq2
                          }
         }
  where AxB-obj = _X_.obj AxB
        BxC-obj = _X_.obj BxC
        Ax[BxC]-obj = _X_.obj Ax[BxC]
        [AxB]xC-obj = _X_.obj [AxB]xC
        π₁-Ax[BxC] = _X_.π₁ Ax[BxC]
        π₂-Ax[BxC] = _X_.π₂ Ax[BxC]
        π₁-[AxB]xC = _X_.π₁ [AxB]xC
        π₂-[AxB]xC = _X_.π₂ [AxB]xC
        π₁-BxC = _X_.π₁ BxC
        π₂-BxC = _X_.π₂ BxC
        π₁-AxB = _X_.π₁ AxB
        π₂-AxB = _X_.π₂ AxB
        d-eu : exist-unique-P (λ d → π₁-BxC ∘ d ≡ π₂-AxB ∘ π₁-[AxB]xC × π₂-BxC ∘ d ≡ π₂-[AxB]xC)
        d-eu = _X_.proof BxC {[AxB]xC-obj} {π₂-AxB ∘ π₁-[AxB]xC} {π₂-[AxB]xC}
        d : morC [AxB]xC-obj BxC-obj
        d = exist-unique-P.! d-eu
        g-eu : exist-unique-P (λ g → π₁-Ax[BxC] ∘ g ≡ π₁-AxB ∘ π₁-[AxB]xC × π₂-Ax[BxC] ∘ g ≡ d)
        g-eu = _X_.proof Ax[BxC] {[AxB]xC-obj} {π₁-AxB ∘ π₁-[AxB]xC} {d}
        g : morC [AxB]xC-obj Ax[BxC]-obj
        g = exist-unique-P.! g-eu
        t-eu : exist-unique-P (λ t → π₁-AxB ∘ t ≡ π₁-Ax[BxC] × π₂-AxB ∘ t ≡ π₁-BxC ∘ π₂-Ax[BxC])
        t-eu = _X_.proof AxB {Ax[BxC]-obj} {π₁-Ax[BxC]} {π₁-BxC ∘ π₂-Ax[BxC]}
        t : morC Ax[BxC]-obj AxB-obj
        t = exist-unique-P.! t-eu
        f-eu : exist-unique-P (λ f → π₁-[AxB]xC ∘ f ≡ t × π₂-[AxB]xC ∘ f ≡ π₂-BxC ∘ π₂-Ax[BxC])
        f-eu = _X_.proof [AxB]xC {Ax[BxC]-obj} {t} {π₂-BxC ∘ π₂-Ax[BxC]}
        f : morC Ax[BxC]-obj [AxB]xC-obj
        f = exist-unique-P.! f-eu
        eq1 : π₁-[AxB]xC ∘ (f ∘ g) ≡ π₁-[AxB]xC × π₂-[AxB]xC ∘ (f ∘ g) ≡ π₂-[AxB]xC
        eq1 = (begin
            π₁-[AxB]xC ∘ (f ∘ g)
          ≡⟨ ∘-assoc ⟩
            (π₁-[AxB]xC ∘ f) ∘ g
          ≡⟨ {!!} ⟩
            t ∘ g
          ≡⟨ {!!} ⟩
            π₁-[AxB]xC
          ∎) , (begin
            π₂-[AxB]xC ∘ (f ∘ g)
          ≡⟨ ∘-assoc ⟩
            (π₂-[AxB]xC ∘ f) ∘ g
          ≡⟨ cong (λ e → e ∘ g) (proj₂ (exist-unique-P.proof f-eu)) ⟩
            (π₂-BxC ∘ π₂-Ax[BxC]) ∘ g
          ≡⟨ {!!} ⟩
            π₂-[AxB]xC
          ∎)
        eq2 : π₁-Ax[BxC] ∘ (g ∘ f) ≡ π₁-Ax[BxC] × π₂-Ax[BxC] ∘ (g ∘ f) ≡ π₂-Ax[BxC]
        eq2 = (begin
            π₁-Ax[BxC] ∘ (g ∘ f)
          ≡⟨ {!!} ⟩
            π₁-Ax[BxC]
          ∎) , (begin
            π₂-Ax[BxC] ∘ (g ∘ f)
          ≡⟨ {!!} ⟩
            π₂-Ax[BxC]
          ∎)

-- -- Theorem 2.2.4
-- -- For any object A, B, A X B ≅ B X A
-- ≅-sym-bproduct : {A B : obC} → {AxB : A X B} → {BxA : B X A} → _X_.obj AxB ≅ _X_.obj BxA
-- ≅-sym-bproduct {A}{B} {AxB} {BxA} =
--   record { f = f
--          ; g = g
--          ; proof = record { invR = unique→id {_}{_} {g} {f} BxA→BxA-unique
--                           ; invL = unique→id {_}{_} {f} {g} AxB→AxB-unique
--                           }
--          }
--   where AxB-obj = _X_.obj AxB
--         BxA-obj = _X_.obj BxA
--         π₁-AxB = _X_.π₁ AxB
--         π₂-AxB = _X_.π₂ AxB
--         π₁-BxA = _X_.π₁ BxA
--         π₂-BxA = _X_.π₂ BxA
--         p1 : exist-unique AxB-obj BxA-obj
--         p1 = proj₁ (_X_.proof BxA {AxB-obj} {π₂-AxB} {π₁-AxB})
--         f : morC AxB-obj BxA-obj
--         f = exist-unique.! p1
--         p2 : exist-unique BxA-obj AxB-obj
--         p2 = proj₁ (_X_.proof AxB {BxA-obj} {π₂-BxA} {π₁-BxA})
--         g : morC BxA-obj AxB-obj
--         g = exist-unique.! p2
--         AxB→AxB-unique : exist-unique AxB-obj AxB-obj
--         AxB→AxB-unique = bproduct-refl-id AxB
--         BxA→BxA-unique : exist-unique BxA-obj BxA-obj
--         BxA→BxA-unique = bproduct-refl-id BxA

-- -- Theorem 2.2.6
-- {- In a category C with binary products, any object A is isomorphic 1 x A -}
-- A≅1xA : {A one : obC} → {1xA : one X A} → {t : terminal one} → A ≅ _X_.obj 1xA
-- A≅1xA {A}{one} {1xA} {t} =
--   record { f = ⟨!A,idA⟩
--          ; g = π₂-1xA
--          ; proof = record { invR = p1
--                           ; invL = p2
--                           }
--          }
--   where 1xA-obj = _X_.obj 1xA
--         π₂-1xA : morC 1xA-obj A
--         π₂-1xA = _X_.π₂ 1xA
--         !A-unique : exist-unique A one
--         !A-unique = terminal.proof t {A}
--         !A : morC A one
--         !A = exist-unique.! !A-unique
--         ⟨!A,idA⟩ : morC A 1xA-obj
--         ⟨!A,idA⟩ = exist-unique.! (proj₁ (_X_.proof 1xA {A} { !A} {id A}))
--         1→1-unique : exist-unique one one
--         1→1-unique = terminal.proof t {one}
--         p1 : ⟨!A,idA⟩ ∘ π₂-1xA ≡ id 1xA-obj
--         p1 = unique→id (bproduct-refl-id 1xA)
--         p2 : π₂-1xA ∘ ⟨!A,idA⟩ ≡ id A
--         p2 = proj₂ (proj₂ (_X_.proof 1xA {A} { !A}{id A}))

-- -- Def 2.2.5
-- -- ⟨ f , f′ ⟩
-- record <_,_> {A B C : obC} (f : morC C A) (g : morC C B) {AxB : A X B} : Set where
--   field
--     m : morC C (_X_.obj AxB)

-- -- f × f′
-- mor-x : {A A′ B B′ : obC} → (f : morC A B) → (f′ : morC A′ B′) → {AxA′ : A X A′} → {BxB′ : B X B′} → Set
-- mor-x f f′ {AxA′} {BxB′} = < f ∘ (_X_.π₁ AxA′) , f′ ∘ (_X_.π₂ AxA′) > {BxB′}

-- -- get instance
-- ⟨_⟩ : {A B C : obC} → {f : morC C A} → {g : morC C B} → {AxB : A X B} →
--        < f , g > {AxB} → morC C (_X_.obj AxB)
-- ⟨_⟩ mp = <_,_>.m mp

-- -- Exercise 2.2.7.
-- {- Show that each of the following equations hold (f : A → B, f′ : A → B′, g : B → C, g′ : B′ → C′) -}
-- ⟨idAxidA′⟩≡idA×A′ : {A A′ : obC} → {AxA′ : A X A′} →
--                   {idAxidA′ : mor-x (id A) (id A′) {AxA′} {AxA′}} →
--                   ⟨ idAxidA′ ⟩ ≡ id (_X_.obj AxA′)
-- ⟨idAxidA′⟩≡idA×A′ {A}{A′} {AxA′} {idAxidA′} = ≡-trans (sym p2) p1
--   where AxA′-obj = _X_.obj (AxA′)
--         ⟨idAxidA′⟩ : morC AxA′-obj AxA′-obj
--         ⟨idAxidA′⟩ = ⟨ idAxidA′ ⟩
--         p1 : ⟨idAxidA′⟩ ∘ (id AxA′-obj) ≡ id AxA′-obj
--         p1 = unique→id (bproduct-refl-id AxA′)
--         p2 : ⟨idAxidA′⟩ ∘ (id AxA′-obj) ≡ ⟨idAxidA′⟩
--         p2 = idR

-- mproduct-dist : {A B B′ C C′ : obC} → {f : morC A B} → {f′ : morC A B′} →
--                 {g : morC B C} → {g′ : morC B′ C′} →
--                 {AxA : A X A} → {BxB′ : B X B′} → {CxC′ : C X C′} →
--                 {gxg′ : mor-x g g′ {BxB′} {CxC′}} →
--                 {fxf′ : mor-x f f′ {AxA} {BxB′}} →
--                 {g∘f×g′∘f′ : mor-x (g ∘ f) (g′ ∘ f′) {AxA} {CxC′}} →
--                 ⟨ gxg′ ⟩ ∘ ⟨ fxf′ ⟩ ≡ ⟨ g∘f×g′∘f′ ⟩
-- mproduct-dist {A}{B}{B′}{C}{C′} {f}{f′} {g}{g′}
--               {AxA} {BxB′} {CxC′}
--               {gxg′}{fxf′}{g∘f×g′∘f′} = pf
--   where AxA-obj = _X_.obj AxA
--         BxB́′-obj = _X_.obj BxB′
--         CxC′-obj = _X_.obj CxC′
--         ⟨gxg′⟩ : morC BxB́′-obj CxC′-obj
--         ⟨gxg′⟩ = ⟨ gxg′ ⟩
--         ⟨fxf′⟩ : morC AxA-obj BxB́′-obj
--         ⟨fxf′⟩ = ⟨ fxf′ ⟩
--         ⟨gxg′⟩∘⟨fxf′⟩ : morC AxA-obj CxC′-obj
--         ⟨gxg′⟩∘⟨fxf′⟩ = ⟨ gxg′ ⟩ ∘ ⟨ fxf′ ⟩
--         ⟨g∘f×g′∘f′⟩ : morC AxA-obj CxC′-obj
--         ⟨g∘f×g′∘f′⟩ = ⟨ g∘f×g′∘f′ ⟩
--         AxA′→CxC′-unique : exist-unique AxA-obj CxC′-obj
--         AxA′→CxC′-unique = proj₁ (_X_.proof CxC′ {AxA-obj} {h1} {h2})
--           where h1 : morC AxA-obj C
--                 h1 = _X_.π₁ CxC′ ∘ ⟨gxg′⟩∘⟨fxf′⟩
--                 h2 : morC AxA-obj C′
--                 h2 = _X_.π₂ CxC′ ∘ ⟨gxg′⟩∘⟨fxf′⟩
--         pf : ⟨gxg′⟩∘⟨fxf′⟩ ≡ ⟨g∘f×g′∘f′⟩
--         pf = exist-unique→f≡g AxA′→CxC′-unique

-- mpair-dist : {A B B′ C C′ : obC} → {f : morC A B} → {f′ : morC A B′} →
--              {g : morC B C} → {g′ : morC B′ C′} →
--              {BxB′ : B X B′} → {CxC′ : C X C′} →
--              {gxg′ : mor-x g g′ {BxB′} {CxC′} } →
--              {f,f′ : < f , f′ > {BxB′} } →
--              {g∘f,g′∘f′ : < g ∘ f , g′ ∘ f′ > {CxC′}} →
--              ⟨ gxg′ ⟩ ∘ ⟨ f,f′ ⟩ ≡ ⟨ g∘f,g′∘f′ ⟩
-- mpair-dist {A}{B}{B′}{C}{C′} {f}{f′} {g}{g′}
--            {BxB′} {CxC′}
--            {gxg′} {f,f′} {g∘f,g′∘f′} = pf
--   where BxB′-obj = _X_.obj BxB′
--         CxC′-obj = _X_.obj CxC′
--         ⟨f,f′⟩ : morC A BxB′-obj
--         ⟨f,f′⟩ = ⟨ f,f′ ⟩
--         ⟨gxg′⟩ : morC BxB′-obj CxC′-obj
--         ⟨gxg′⟩ = ⟨ gxg′ ⟩
--         ⟨gxg′⟩∘⟨f,f′⟩ : morC A CxC′-obj
--         ⟨gxg′⟩∘⟨f,f′⟩ = ⟨ gxg′ ⟩ ∘ ⟨ f,f′ ⟩
--         ⟨g∘f,g′∘f′⟩ : morC A CxC′-obj
--         ⟨g∘f,g′∘f′⟩ = ⟨ g∘f,g′∘f′ ⟩
--         A→CxC′-unique : exist-unique A CxC′-obj
--         A→CxC′-unique = proj₁ (_X_.proof CxC′ {A} {h1} {h2})
--           where h1 : morC A C
--                 h1 = _X_.π₁ CxC′ ∘ ⟨gxg′⟩∘⟨f,f′⟩
--                 h2 : morC A C′
--                 h2 = _X_.π₂ CxC′ ∘ ⟨gxg′⟩∘⟨f,f′⟩
--         pf : ⟨gxg′⟩∘⟨f,f′⟩ ≡ ⟨g∘f,g′∘f′⟩
--         pf = exist-unique→f≡g A→CxC′-unique

-- -- Def 2.2.9.
-- record Δ (A : obC) : Set where
--   field
--     bp : A X A
--     m : morC A (_X_.obj bp)

-- -- Exercise 2.2.10
-- {- Show that, if a category C has binary products, ⟨h,k⟩ = hxk ∘ ΔT
--    for any h : T → A and k : T → B -}
-- ⟨h,k⟩≡⟨hxk⟩∘ΔT : {A B T : obC} → {h : morC T A} → {k : morC T B} →
--                  {AxB : A X B} →
--                  {ΔT : Δ T} →
--                  {h,k : < h , k > {AxB}} →
--                  {hxk : mor-x h k {Δ.bp ΔT} {AxB}} →
--                  ⟨ h,k ⟩ ≡ ⟨ hxk ⟩ ∘ Δ.m ΔT
-- ⟨h,k⟩≡⟨hxk⟩∘ΔT {A}{B}{T} {h}{k}
--                {AxB} {ΔT} {h,k} {hxk} = pf
--   where AxB-obj = _X_.obj AxB
--         TxT = Δ.bp ΔT
--         TxT-obj = _X_.obj TxT
--         TxT-m = Δ.m ΔT
--         ⟨h,k⟩ : morC T AxB-obj
--         ⟨h,k⟩ = ⟨ h,k ⟩
--         ⟨hxk⟩ : morC TxT-obj AxB-obj
--         ⟨hxk⟩ = ⟨ hxk ⟩
--         ⟨hxk⟩∘ΔT : morC T AxB-obj
--         ⟨hxk⟩∘ΔT = ⟨hxk⟩ ∘ Δ.m ΔT
--         T→AxB-unique : exist-unique T AxB-obj
--         T→AxB-unique = proj₁ (_X_.proof AxB {T} {h1} {h2})
--           where h1 : morC T A
--                 h1 = _X_.π₁ AxB ∘ ⟨h,k⟩
--                 h2 : morC T B
--                 h2 = _X_.π₂ AxB ∘ ⟨h,k⟩
--         pf : ⟨h,k⟩ ≡ ⟨hxk⟩∘ΔT
--         pf = exist-unique→f≡g T→AxB-unique

-- -- Def 2.2.11
-- -- Binary-coproduct
-- record _+_ (A B : obC) : Set where
--   field
--     obj : obC
--     ι₁ : morC A obj
--     ι₂ : morC B obj
--     proof : {C : obC} → {f : morC A C} → {g : morC B C} →
--             Σ[ A+B→C-unique ∈ exist-unique obj C ]
--             (exist-unique.! A+B→C-unique) ∘ ι₁ ≡ f × (exist-unique.! A+B→C-unique) ∘ ι₂ ≡ g

-- cproduct-unique-refl : {A B : obC} → (A+B : A + B) → exist-unique (_+_.obj A+B) (_+_.obj A+B)
-- cproduct-unique-refl {A}{B} A+B = proj₁ (_+_.proof A+B {_} {ι₁} {ι₂})
--   where ι₁ = _+_.ι₁ A+B
--         ι₂ = _+_.ι₂ A+B

-- -- Theorem 2.2.12
-- {- For any objects A and B, a binary coproduct of A and B is unique up morphism. -}
-- A+B-unique : {A B : obC} → {P P′ : A + B} → _+_.obj P ≅ _+_.obj P′
-- A+B-unique {A}{B} {P}{P′} =
--   record { f = f
--          ; g = g
--          ; proof = record { invR = p1
--                           ; invL = p2
--                           }
--          }
--   where P-obj = _+_.obj P
--         P′-obj = _+_.obj P′
--         ι₁-p = _+_.ι₁ P
--         ι₂-p = _+_.ι₂ P
--         ι₁-p′ = _+_.ι₁ P′
--         ι₂-p′ = _+_.ι₂ P′
--         f : morC P-obj P′-obj
--         f = exist-unique.! (proj₁ (_+_.proof P {P′-obj} {ι₁-p′} {ι₂-p′}))
--         g : morC P′-obj P-obj
--         g = exist-unique.! (proj₁ (_+_.proof P′ {P-obj} {ι₁-p} {ι₂-p}))
--         P→P-unique : exist-unique P-obj P-obj
--         P→P-unique = cproduct-unique-refl P
--         P′→P′-unique : exist-unique P′-obj P′-obj
--         P′→P′-unique = cproduct-unique-refl P′
--         p1 : (f ∘ g) ≡ id P′-obj
--         p1 = unique→id P′→P′-unique
--         p2 : (g ∘ f) ≡ id P-obj
--         p2 = unique→id P→P-unique

-- -- Theorem 2.2.13.
-- {- In a category C with binary coproducts, any object A is isomorphoc ⊘ + A -}
-- A≅⊘+A : {A : obC} → {⊘ : obC} → {i : initial ⊘} → {⊘+A : ⊘ + A} → A ≅ _+_.obj ⊘+A
-- A≅⊘+A {A}{⊘} {init} {⊘+A} =
--   record { f = f
--          ; g = g
--          ; proof = record { invR = p1
--                           ; invL = p2
--                           }
--          }
--   where ⊘+A-obj = _+_.obj ⊘+A
--         f : morC A ⊘+A-obj
--         f = _+_.ι₂ ⊘+A
--         h : morC ⊘ A
--         h = exist-unique.! (initial.proof init {A})
--         ⊘+A→A-unique : exist-unique ⊘+A-obj A
--         ⊘+A→A-unique = proj₁ (_+_.proof ⊘+A {A} {h} {id A})
--         g : morC ⊘+A-obj A
--         g = exist-unique.! ⊘+A→A-unique
--         ⊘+A→⊘+A-unique : exist-unique ⊘+A-obj ⊘+A-obj
--         ⊘+A→⊘+A-unique = cproduct-unique-refl ⊘+A
--         p1 : f ∘ g ≡ id ⊘+A-obj
--         p1 = unique→id ⊘+A→⊘+A-unique
--         p2 : g ∘ f ≡ id A
--         p2 = proj₂ (proj₂ (_+_.proof ⊘+A {A} {h} {id A}))

-- -- Theorem 2.2.13.
-- {- For any objects A, B, A + B ≅ B + A -}
-- cproduct-sym : {A B : obC} → {A+B : A + B} → {B+A : B + A} →
--                _+_.obj A+B ≅ _+_.obj B+A
-- cproduct-sym {A}{B} {A+B}{B+A} =
--   record { f = f
--          ; g = g
--          ; proof = record { invR = p1
--                           ; invL = p2
--                           }
--          }
--   where ι₁-A+B = _+_.ι₁ A+B
--         ι₂-A+B = _+_.ι₂ A+B
--         ι₁-B+A = _+_.ι₁ B+A
--         ι₂-B+A = _+_.ι₂ B+A
--         A+B-obj = _+_.obj A+B
--         B+A-obj = _+_.obj B+A
--         f : morC A+B-obj B+A-obj
--         f = exist-unique.! (proj₁ (_+_.proof A+B {B+A-obj} {ι₂-B+A} {ι₁-B+A}))
--         g : morC B+A-obj A+B-obj
--         g = exist-unique.! (proj₁ (_+_.proof B+A {A+B-obj} {ι₂-A+B} {ι₁-A+B}))
--         A+B→A+B-unique : exist-unique A+B-obj A+B-obj
--         A+B→A+B-unique = cproduct-unique-refl A+B
--         B+A→B+A-unique : exist-unique B+A-obj B+A-obj
--         B+A→B+A-unique = cproduct-unique-refl B+A
--         p1 : f ∘ g ≡ id B+A-obj
--         p1 = unique→id B+A→B+A-unique
--         p2 : g ∘ f ≡ id A+B-obj
--         p2 = unique→id A+B→A+B-unique

-- -- Exercise 2.2.15.
-- {- Show that the coproduct constructions are assosiative -}
-- +-assoc : {A B C : obC} → {B+C : B + C} → {A+[B+C] : A + (_+_.obj B+C)} →
--           {A+B : A + B} → {[A+B]+C : (_+_.obj A+B) + C} →
--           _+_.obj A+[B+C] ≅ _+_.obj [A+B]+C
-- +-assoc {A}{B}{C} {B+C}{A+[B+C]}{A+B}{[A+B]+C} =
--   record { f = f
--          ; g = g
--          ; proof = record { invR = p1
--                           ; invL = p2
--                           }
--          }
--   where A+B-obj = _+_.obj A+B
--         B+C-obj = _+_.obj B+C
--         A+[B+C]-obj = _+_.obj A+[B+C]
--         [A+B]+C-obj = _+_.obj [A+B]+C
--         f : morC A+[B+C]-obj [A+B]+C-obj
--         f = exist-unique.! (proj₁ (_+_.proof A+[B+C] {[A+B]+C-obj} {h1} {h2}))
--           where h1 : morC A [A+B]+C-obj
--                 h1 = _+_.ι₁ [A+B]+C ∘ _+_.ι₁ A+B
--                 h2 : morC B+C-obj [A+B]+C-obj
--                 h2 = exist-unique.! (proj₁ (_+_.proof B+C {[A+B]+C-obj} {k1} {k2}))
--                      where k1 : morC B [A+B]+C-obj
--                            k1 = _+_.ι₁ [A+B]+C ∘ _+_.ι₂ A+B
--                            k2 : morC C [A+B]+C-obj
--                            k2 = _+_.ι₂ [A+B]+C
--         g : morC [A+B]+C-obj A+[B+C]-obj
--         g = exist-unique.! (proj₁ (_+_.proof [A+B]+C {A+[B+C]-obj} {h1} {h2}))
--           where h1 : morC A+B-obj A+[B+C]-obj
--                 h1 = exist-unique.! (proj₁ (_+_.proof A+B {A+[B+C]-obj} {k1} {k2}))
--                      where k1 : morC A A+[B+C]-obj
--                            k1 = _+_.ι₁ A+[B+C]
--                            k2 : morC B A+[B+C]-obj
--                            k2 = _+_.ι₂ A+[B+C] ∘ _+_.ι₁ B+C
--                 h2 : morC C A+[B+C]-obj
--                 h2 = _+_.ι₂ A+[B+C] ∘ _+_.ι₂ B+C
--         [A+B]+C→[A+B]+C-unique : exist-unique [A+B]+C-obj [A+B]+C-obj
--         [A+B]+C→[A+B]+C-unique = cproduct-unique-refl [A+B]+C
--         A+[B+C]→A+[B+C]-unique : exist-unique A+[B+C]-obj A+[B+C]-obj
--         A+[B+C]→A+[B+C]-unique = cproduct-unique-refl A+[B+C]
--         p1 : f ∘ g ≡ id [A+B]+C-obj
--         p1 = unique→id [A+B]+C→[A+B]+C-unique
--         p2 : g ∘ f ≡ id A+[B+C]-obj
--         p2 = unique→id A+[B+C]→A+[B+C]-unique

-- {-
--   record exist-unique-P {A : Set} (P : A → Set) : Set where
--   field
--     ! : A
--     proof : P !
--     unique : (o : A) → P o → o ≡ !

--   record exist-unique_to_ (A B : obC) : Set where
--   field
--     m : morC A B
--     unique : (m′ : morC A B) → m′ ≡ m
-- -}

-- record pullback {A B C : obC} (f : morC A C) (g : morC B C) : Set where
--   field
--     obj : obC -- A Xc B
--     p₁ : morC obj A
--     p₂ : morC obj B
--     proj-eq : f ∘ p₁ ≡ g ∘ p₂
--     proof : {T : obC} → {h : morC T A} → {k : morC T B} → f ∘ h ≡ g ∘ k →
--             exist-unique-P {morC T obj} (λ m → p₁ ∘ m ≡ h × p₂ ∘ m ≡ k)

-- -- exist-unique→f≡g : {A : Set} → {P : A → Set} → exist-unique-P {A} P →
-- --                    {f g : A} → P f → P g → f ≡ g
-- -- exist-unique→f≡g {A}{P} eu {f}{g} f-pf g-pf = ≡-trans eq1 (sym eq2)
-- --   where ! = exist-unique-P.! eu
-- --         eq1 : f ≡ !
-- --         eq1 = exist-unique-P.unique eu f f-pf
-- --         eq2 : g ≡ !
-- --         eq2 = exist-unique-P.unique eu g g-pf

-- -- {-
-- -- pullback-unique-refl : {A B C : obC} → {f : morC A C} → {g : morC B C} →
-- --                        (D : pullback f g) → exist-unique (pullback.obj D) (pullback.obj D)
-- -- のような関数がほしいが、これは、idR (f ∘ id A ≡ f) の一般形
-- -- つまり、全ての m : A → A に対して、 f ∘ m ≡ f を示そうとしているようなものである。
-- -- -}
-- -- pullback-id : {A B C : obC} → {f : morC A C} → {g : morC B C} →
-- --               (D : pullback f g) →
-- --               {t : morC (pullback.obj D) (pullback.obj D)} →
-- --               pullback.p₁ D ∘ t ≡ pullback.p₁ D × pullback.p₂ D ∘ t ≡ pullback.p₂ D →
-- --               t ≡ id (pullback.obj D)
-- -- pullback-id {A}{B}{C} {f}{g} D {t} t-proj-eq = ≡-trans t≡! (sym id≡!)
-- --   where p₁ = pullback.p₁ D
-- --         p₂ = pullback.p₂ D
-- --         obj = pullback.obj D
-- --         eq = pullback.proj-eq D
-- --         eu : exist-unique-P (λ m → p₁ ∘ m ≡ p₁ × p₂ ∘ m ≡ p₂)
-- --         eu = pullback.proof D eq
-- --         ! = exist-unique-P.! eu
-- --         id≡! : id obj ≡ !
-- --         id≡! = exist-unique-P.unique eu (id obj) (idR , idR)
-- --         t≡! : t ≡ !
-- --         t≡! = exist-unique-P.unique eu t t-proj-eq

-- -- -- Theorem 2.3.2
-- -- {- A pullback for a given pair of morphisms is determined up isomorphism. -}
-- -- pullback-unique : {A B C : obC} → {f : morC A C} → {g : morC B C} →
-- --                   {D : pullback f g} → {E : pullback f g} → pullback.obj D ≅ pullback.obj E
-- -- pullback-unique {A}{B}{C} {f}{g} {D}{E} =
-- --   record { f = !D→E
-- --          ; g = !E→D
-- --          ; proof = record { invR = pullback-id E eq1
-- --                           ; invL = pullback-id D eq2
-- --                           }
-- --          }
-- --   where D-obj = pullback.obj D
-- --         E-obj = pullback.obj E
-- --         Da = pullback.p₁ D
-- --         Db = pullback.p₂ D
-- --         Ea = pullback.p₁ E
-- --         Eb = pullback.p₂ E
-- --         D-eq : f ∘ Da ≡ g ∘ Db
-- --         D-eq = pullback.proj-eq D
-- --         E-eq : f ∘ Ea ≡ g ∘ Eb
-- --         E-eq = pullback.proj-eq E
-- --         !E→D-unique : exist-unique-P (λ m → Da ∘ m ≡ Ea × Db ∘ m ≡ Eb)
-- --         !E→D-unique = pullback.proof D E-eq
-- --         !D→E-unique : exist-unique-P (λ m → Ea ∘ m ≡ Da × Eb ∘ m ≡ Db)
-- --         !D→E-unique = pullback.proof E D-eq
-- --         !D→E : morC D-obj E-obj
-- --         !D→E = exist-unique-P.! !D→E-unique
-- --         !E→D : morC E-obj D-obj
-- --         !E→D = exist-unique-P.! !E→D-unique
-- --         !E→D-pf : Da ∘ !E→D ≡ Ea × Db ∘ !E→D ≡ Eb
-- --         !E→D-pf = exist-unique-P.proof !E→D-unique
-- --         !D→E-pf : Ea ∘ !D→E ≡ Da × Eb ∘ !D→E ≡ Db
-- --         !D→E-pf = exist-unique-P.proof !D→E-unique
-- --         eq1 : Ea ∘ (!D→E ∘ !E→D) ≡ Ea × Eb ∘ (!D→E ∘ !E→D) ≡ Eb
-- --         eq1 = (begin
-- --               Ea ∘ (!D→E ∘ !E→D)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (Ea ∘ !D→E) ∘ !E→D
-- --             ≡⟨ cong (λ e → e ∘ !E→D) (proj₁ !D→E-pf) ⟩
-- --               Da ∘ !E→D
-- --             ≡⟨ proj₁ !E→D-pf ⟩
-- --               Ea
-- --             ∎) , (begin
-- --               Eb ∘ (!D→E ∘ !E→D)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (Eb ∘ !D→E) ∘ !E→D
-- --             ≡⟨ cong (λ e → e ∘ !E→D) (proj₂ !D→E-pf) ⟩
-- --               Db ∘ !E→D
-- --             ≡⟨ proj₂ !E→D-pf ⟩
-- --               Eb
-- --             ∎)
-- --         eq2 : Da ∘ (!E→D ∘ !D→E) ≡ Da × Db ∘ (!E→D ∘ !D→E) ≡ Db
-- --         eq2 = (begin
-- --               Da ∘ (!E→D ∘ !D→E)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (Da ∘ !E→D) ∘ !D→E
-- --             ≡⟨ cong (λ e → e ∘ !D→E) (proj₁ !E→D-pf) ⟩
-- --               Ea ∘ !D→E
-- --             ≡⟨ proj₁ !D→E-pf ⟩
-- --               Da
-- --             ∎) , (begin
-- --               Db ∘ (!E→D ∘ !D→E)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (Db ∘ !E→D) ∘ !D→E
-- --             ≡⟨ cong (λ e → e ∘ !D→E) (proj₂ !E→D-pf) ⟩
-- --               Eb ∘ !D→E
-- --             ≡⟨ proj₂ !D→E-pf ⟩
-- --               Db
-- --             ∎)

-- -- -- Theorem 2.3.3.
-- -- pullback-monic : {A B C : obC} → {f : morC A C} → {g : morC B C} →
-- --                  {D : pullback f g} → monic f → monic (pullback.p₂ D)
-- -- pullback-monic {A}{B}{C} {f}{g} {D} monic-f {T}{t₁}{t₂} p₂∘t₁≡p₂∘t₂ = pf
-- --   where D-obj = pullback.obj D
-- --         p₁ = pullback.p₁ D
-- --         p₂ = pullback.p₂ D
-- --         h : morC T A
-- --         h = p₁ ∘ t₂
-- --         k : morC T B
-- --         k = p₂ ∘ t₁
-- --         D-eq : f ∘ p₁ ≡ g ∘ p₂
-- --         D-eq = pullback.proj-eq D
-- --         eq : f ∘ h ≡ g ∘ k
-- --         eq = begin
-- --               f ∘ (p₁ ∘ t₂)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (f ∘ p₁) ∘ t₂
-- --             ≡⟨ cong (λ x → x ∘ t₂) D-eq ⟩
-- --               (g ∘ p₂) ∘ t₂
-- --             ≡⟨ sym ∘-assoc ⟩
-- --               g ∘ (p₂ ∘ t₂)
-- --             ≡⟨ cong (λ x → g ∘ x) (sym p₂∘t₁≡p₂∘t₂) ⟩
-- --               g ∘ (p₂ ∘ t₁)
-- --             ∎
-- --         !T→D-unique : exist-unique-P (λ m → p₁ ∘ m ≡ h × p₂ ∘ m ≡ k)
-- --         !T→D-unique = pullback.proof D eq
-- --         !T→D : morC T D-obj
-- --         !T→D = exist-unique-P.! !T→D-unique
-- --         eq1 : p₁ ∘ t₁ ≡ h × p₂ ∘ t₁ ≡ k
-- --         eq1 = monic-f e , refl
-- --           where e : f ∘ (p₁ ∘ t₁) ≡ f ∘ h
-- --                 e = begin
-- --                       f ∘ (p₁ ∘ t₁)
-- --                     ≡⟨ ∘-assoc ⟩
-- --                       (f ∘ p₁) ∘ t₁
-- --                     ≡⟨ cong (λ e → e ∘ t₁) D-eq ⟩
-- --                       (g ∘ p₂) ∘ t₁
-- --                     ≡⟨ sym ∘-assoc ⟩
-- --                       g ∘ (p₂ ∘ t₁)
-- --                     ≡⟨ sym eq ⟩
-- --                       f ∘ (p₁ ∘ t₂)
-- --                     ∎
-- --         eq2 : p₁ ∘ t₂ ≡ h × p₂ ∘ t₂ ≡ k
-- --         eq2 = refl , sym p₂∘t₁≡p₂∘t₂
-- --         pf : t₁ ≡ t₂
-- --         pf = exist-unique→f≡g !T→D-unique eq1 eq2

-- -- -- Theorem 2.3.4.
-- -- outer-pullback : {A₁ A₂ B₁ C : obC} →
-- --                  {f₁ : morC A₁ C} → {g₁ : morC B₁ C} →
-- --                  (D₁ : pullback f₁ g₁) →
-- --                  {f₂ : morC A₂ A₁} →
-- --                  (D₂ : pullback f₂ (pullback.p₁ D₁)) →
-- --                  pullback (f₁ ∘ f₂) g₁
-- -- outer-pullback {A₁}{A₂}{B₁}{C} {f₁}{g₁} D₁ {f₂} D₂ =
-- --   record { obj = D₂-obj
-- --          ; p₁ = Da₂
-- --          ; p₂ = Db₁ ∘ Db₂
-- --          ; proj-eq = eq
-- --          ; proof = pf
-- --          }
-- --   where D₁-obj = pullback.obj D₁
-- --         D₂-obj = pullback.obj D₂
-- --         Da₁ : morC D₁-obj A₁
-- --         Da₁ = pullback.p₁ D₁
-- --         Db₁ : morC D₁-obj B₁
-- --         Db₁ = pullback.p₂ D₁
-- --         Da₂ : morC D₂-obj A₂
-- --         Da₂ = pullback.p₁ D₂
-- --         Db₂ : morC D₂-obj D₁-obj
-- --         Db₂ = pullback.p₂ D₂
-- --         eq : ((f₁ ∘ f₂) ∘ Da₂) ≡ (g₁ ∘ (Db₁ ∘ Db₂))
-- --         eq = begin
-- --               (f₁ ∘ f₂) ∘ Da₂
-- --             ≡⟨ sym ∘-assoc ⟩
-- --               f₁ ∘ (f₂ ∘ Da₂)
-- --             ≡⟨ cong (λ x → f₁ ∘ x) eq₂ ⟩
-- --               f₁ ∘ (Da₁ ∘ Db₂)
-- --             ≡⟨ ∘-assoc ⟩
-- --               (f₁ ∘ Da₁) ∘ Db₂
-- --             ≡⟨ cong (λ x → x ∘ Db₂) eq₁ ⟩
-- --               (g₁ ∘ Db₁) ∘ Db₂
-- --             ≡⟨ sym ∘-assoc ⟩
-- --               g₁ ∘ (Db₁ ∘ Db₂)
-- --             ∎
-- --            where eq₁ : f₁ ∘ Da₁ ≡ g₁ ∘ Db₁
-- --                  eq₁ = pullback.proj-eq D₁
-- --                  eq₂ : f₂ ∘ Da₂ ≡ Da₁ ∘ Db₂
-- --                  eq₂ = pullback.proj-eq D₂
-- --         pf : {T : obC} {h : morC T A₂} {k : morC T B₁} →
-- --              ((f₁ ∘ f₂) ∘ h) ≡ (g₁ ∘ k) →
-- --              exist-unique-P (λ m → Da₂ ∘ m ≡ h × (Db₁ ∘ Db₂) ∘ m ≡ k)
-- --         pf {T}{h}{k} [f₁∘f₂]∘h≡g₁∘k =
-- --             record { ! = l-mor
-- --                    ; proof = proj₁ (exist-unique-P.proof left) , eq′′
-- --                    ; unique = λ m′ m′-pf →
-- --                               exist-unique-P.unique left m′ (proj₁ m′-pf ,
-- --                                 exist-unique-P.unique right (Db₂ ∘ m′) ((begin
-- --                                     Da₁ ∘ (Db₂ ∘ m′)
-- --                                   ≡⟨ ∘-assoc ⟩
-- --                                     (Da₁ ∘ Db₂) ∘ m′
-- --                                   ≡⟨ cong (λ e → e ∘ m′) (sym (pullback.proj-eq D₂)) ⟩
-- --                                     (f₂ ∘ Da₂) ∘ m′
-- --                                   ≡⟨ sym ∘-assoc ⟩
-- --                                     f₂ ∘ (Da₂ ∘ m′)
-- --                                   ≡⟨ cong (λ e → f₂ ∘ e) (proj₁ m′-pf) ⟩
-- --                                     f₂ ∘ h
-- --                                   ∎), (begin
-- --                                     Db₁ ∘ (Db₂ ∘ m′)
-- --                                   ≡⟨ ∘-assoc ⟩
-- --                                     (Db₁ ∘ Db₂) ∘ m′
-- --                                   ≡⟨ proj₂ m′-pf ⟩
-- --                                     k
-- --                                   ∎)))
-- --                    }
-- --            where right : exist-unique-P (λ m → Da₁ ∘ m ≡ f₂ ∘ h × Db₁ ∘ m ≡ k)
-- --                  right = pullback.proof D₁ eq′
-- --                     where eq′ : f₁ ∘ (f₂ ∘ h) ≡ g₁ ∘ k
-- --                           eq′ = begin
-- --                              f₁ ∘ (f₂ ∘ h)
-- --                            ≡⟨ ∘-assoc ⟩
-- --                              (f₁ ∘ f₂) ∘ h
-- --                            ≡⟨ [f₁∘f₂]∘h≡g₁∘k ⟩
-- --                              g₁ ∘ k
-- --                            ∎
-- --                  r-mor : morC T D₁-obj
-- --                  r-mor = exist-unique-P.! right
-- --                  left : exist-unique-P (λ m → Da₂ ∘ m ≡ h × Db₂ ∘ m ≡ r-mor)
-- --                  left = pullback.proof D₂ eq′
-- --                     where eq′ : f₂ ∘ h ≡ Da₁ ∘ r-mor
-- --                           eq′ = sym (proj₁ (exist-unique-P.proof right))
-- --                  l-mor : morC T D₂-obj
-- --                  l-mor = exist-unique-P.! left
-- --                  eq′′ : (Db₁ ∘ Db₂) ∘ l-mor ≡ k
-- --                  eq′′ = begin
-- --                      (Db₁ ∘ Db₂) ∘ l-mor
-- --                    ≡⟨ sym ∘-assoc ⟩
-- --                      Db₁ ∘ (Db₂ ∘ l-mor)
-- --                    ≡⟨ cong (λ x → Db₁ ∘ x) (proj₂ (exist-unique-P.proof left)) ⟩
-- --                      Db₁ ∘ r-mor
-- --                    ≡⟨ proj₂ (exist-unique-P.proof right) ⟩
-- --                      k
-- --                    ∎

-- -- -- Exercise 2.3.5.
-- -- {- Suppose that there is a commutative triangle.
-- --    C ----h-----> D
-- --     \         /
-- --      \       /
-- --      m\     /n
-- --        \   /
-- --         v v
-- --          B
-- --    and suppose that m and n have the following pullbacks along f:
-- --    E---q--->C   F---s--->D
-- --    |        |   |        |
-- --   p|   D₁   |m r|   D₂   |n
-- --    |        |   |        |
-- --    v        v   v        v
-- --    A---f--->B   A---f--->B
-- --    Show that, then, there is a unique u : E -> F
-- --    that makes the following diagrams commute:
-- --    (Omitted)
-- -- -}
-- -- pullback-dbl : {A B C D : obC} →
-- --                {h : morC C D} → {m : morC C B} → {n : morC D B} →
-- --                {_ : m ≡ n ∘ h} →
-- --                {f : morC A B} →
-- --                {D₁ : pullback f m} → {D₂ : pullback f n} →
-- --                exist-unique-P
-- --                  (λ u′ → (pullback.p₁ D₂) ∘ u′ ≡ (pullback.p₁ D₁) ×
-- --                     (pullback.p₂ D₂) ∘ u′ ≡ h ∘ (pullback.p₂ D₁))
-- -- pullback-dbl {A}{B}{C}{D} {h}{m}{n} {m≡n∘h} {f} {D₁}{D₂} = !E→F-unique
-- --   where E = pullback.obj D₁
-- --         F = pullback.obj D₂
-- --         p = pullback.p₁ D₁
-- --         q = pullback.p₂ D₁
-- --         r = pullback.p₁ D₂
-- --         s = pullback.p₂ D₂
-- --         eq : f ∘ p ≡ n ∘ (h ∘ q)
-- --         eq = begin
-- --             f ∘ p
-- --           ≡⟨ pullback.proj-eq D₁ ⟩
-- --             m ∘ q
-- --           ≡⟨ cong (λ e → e ∘ q) m≡n∘h ⟩
-- --             (n ∘ h) ∘ q
-- --           ≡⟨ sym ∘-assoc ⟩
-- --             n ∘ (h ∘ q)
-- --           ∎
-- --         !E→F-unique : exist-unique-P (λ u′ → r ∘ u′ ≡ p × s ∘ u′ ≡ (h ∘ q))
-- --         !E→F-unique = pullback.proof D₂ eq

-- -- record equalizer {A B : obC} (f g : morC A B) : Set where
-- --   field
-- --     E : obC
-- --     e : morC E A
-- --     eq : f ∘ e ≡ g ∘ e
-- --     proof : {T : obC} → {h : morC T A} → f ∘ h ≡ g ∘ h →
-- --             exist-unique-P {morC T E} (λ k → h ≡ e ∘ k)

-- -- {- Theorem 2.4.2 very equalizer is monic. -}
-- -- equalizer→monic : {A B : obC} → {f g : morC A B} →
-- --                   (elz : equalizer f g) → monic (equalizer.e elz)
-- -- equalizer→monic {A}{B} {f}{g} elz {T}{t₁}{t₂} e∘t₁≡e∘t₂ = pf
-- --   where E = equalizer.E elz
-- --         e = equalizer.e elz
-- --         eq : f ∘ (e ∘ t₁) ≡ g ∘ (e ∘ t₁)
-- --         eq = begin
-- --             f ∘ (e ∘ t₁)
-- --           ≡⟨ ∘-assoc ⟩
-- --             (f ∘ e) ∘ t₁
-- --           ≡⟨ cong (λ e → e ∘ t₁) (equalizer.eq elz) ⟩
-- --             (g ∘ e) ∘ t₁
-- --           ≡⟨ sym ∘-assoc ⟩
-- --             g ∘ (e ∘ t₁)
-- --           ∎
-- --         eu : exist-unique-P (λ k → (e ∘ t₁) ≡ e ∘ k)
-- --         eu = equalizer.proof elz eq
-- --         pf : t₁ ≡ t₂
-- --         pf = exist-unique→f≡g eu refl e∘t₁≡e∘t₂

-- -- -- binary product exists for any two objects.
-- -- obC-bproduct : Set
-- -- obC-bproduct = (A B : obC) → A X B

-- -- -- equalizer exists for any two morphisms.
-- -- obC-equalizer : Set
-- -- obC-equalizer = {A B : obC} → (f g : morC A B) → equalizer f g

-- -- {- Theorem 2.4.3
-- --    if a category has all binary products and equalizers for any two morphisms,
-- --    then it has a pullback for any two morphisms f : A -> C and g : B -> C -}
-- -- bp-elz→pullback : {_ : obC-bproduct} → {_ : obC-equalizer} →
-- --                   {A B C : obC} → {f : morC A C} → {g : morC B C} →
-- --                   pullback f g
-- -- bp-elz→pullback {bp}{el} {A}{B}{C} {f}{g} =
-- --   record { obj = E
-- --          ; p₁ = p₁
-- --          ; p₂ = p₂
-- --          ; proj-eq = proj-eq
-- --          ; proof = proof
-- --          }
-- --   where AxB = bp A B
-- --         AxB-obj = _X_.obj AxB
-- --         π₁ = _X_.π₁ AxB
-- --         π₂ = _X_.π₂ AxB
-- --         elz = el (f ∘ π₁) (g ∘ π₂)
-- --         E = equalizer.E elz
-- --         e = equalizer.e elz
-- --         p₁ = π₁ ∘ e
-- --         p₂ = π₂ ∘ e
-- --         elz-eq : (f ∘ π₁) ∘ e ≡ (g ∘ π₂) ∘ e
-- --         elz-eq = equalizer.eq elz
-- --         proj-eq : f ∘ p₁ ≡ g ∘ p₂
-- --         proj-eq = begin
-- --             f ∘ (π₁ ∘ e)
-- --           ≡⟨ ∘-assoc ⟩
-- --             (f ∘ π₁) ∘ e
-- --           ≡⟨ elz-eq ⟩
-- --             (g ∘ π₂) ∘ e
-- --           ≡⟨ sym ∘-assoc ⟩
-- --             g ∘ (π₂ ∘ e)
-- --           ∎
-- --         proof : {T : obC} {s : morC T A} {t : morC T B} →
-- --                 f ∘ s ≡ g ∘ t →
-- --                 exist-unique-P {morC T E} (λ m → (p₁ ∘ m) ≡ s × (p₂ ∘ m) ≡ t)
-- --         proof {T}{s}{t} f∘s≡g∘t =
-- --           record { ! = !
-- --                  ; proof = (begin
-- --                       (π₁ ∘ e) ∘ !
-- --                     ≡⟨ sym ∘-assoc ⟩
-- --                       π₁ ∘ (e ∘ !)
-- --                     ≡⟨ cong (λ x → π₁ ∘ x) (sym eq3) ⟩
-- --                       π₁ ∘ T→AxB
-- --                     ≡⟨ proj₁ eq1 ⟩
-- --                       s
-- --                     ∎) , (begin
-- --                       (π₂ ∘ e) ∘ !
-- --                     ≡⟨ sym ∘-assoc ⟩
-- --                       π₂ ∘ (e ∘ !)
-- --                     ≡⟨ cong (λ x → π₂ ∘ x) (sym eq3) ⟩
-- --                       π₂ ∘ T→AxB
-- --                     ≡⟨ proj₂ eq1 ⟩
-- --                       t
-- --                     ∎)
-- --                  ; unique = λ m′ m′-pf →
-- --                           exist-unique-P.unique eu m′ (begin
-- --                             T→AxB
-- --                           ≡⟨ eq3 ⟩
-- --                             e ∘ !
-- --                           ≡⟨ exist-unique→f≡g T→AxB-unique ⟩
-- --                             e ∘ m′
-- --                           ∎)
-- --                  }
-- --           where T→AxB-unique : exist-unique T AxB-obj
-- --                 T→AxB-unique = proj₁ (_X_.proof AxB {T}{s}{t})
-- --                 T→AxB = exist-unique.! T→AxB-unique
-- --                 eq1 : π₁ ∘ T→AxB ≡ s × π₂ ∘ T→AxB ≡ t
-- --                 eq1 = proj₂ (_X_.proof AxB {T}{s}{t})
-- --                 eq2 : (f ∘ π₁) ∘ T→AxB ≡ (g ∘ π₂) ∘ T→AxB
-- --                 eq2 = begin
-- --                     (f ∘ π₁) ∘ T→AxB
-- --                   ≡⟨ sym ∘-assoc ⟩
-- --                     f ∘ (π₁ ∘ T→AxB)
-- --                   ≡⟨ cong (λ e → f ∘ e) (proj₁ eq1) ⟩
-- --                     f ∘ s
-- --                   ≡⟨ f∘s≡g∘t ⟩
-- --                     g ∘ t
-- --                   ≡⟨ cong (λ e → g ∘ e) (sym (proj₂ eq1)) ⟩
-- --                     g ∘ (π₂ ∘ T→AxB)
-- --                   ≡⟨ ∘-assoc ⟩
-- --                     (g ∘ π₂) ∘ T→AxB
-- --                   ∎
-- --                 eu : exist-unique-P (λ k → T→AxB ≡ e ∘ k)
-- --                 eu = equalizer.proof elz eq2
-- --                 ! = exist-unique-P.! eu
-- --                 eq3 : T→AxB ≡ e ∘ !
-- --                 eq3 = exist-unique-P.proof eu

-- -- -- π₁π₂
-- -- -- ι₁ι₂
-- -- -- p₁p₂
-- -- -- proj₁ proj₂
-- -- -- ∎ λ ₁₂

