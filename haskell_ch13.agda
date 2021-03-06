module haskell_ch13 where

-- for "Programming Haskell" chapter 13.
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning
open import Data.Empty
import Level
open import Relation.Nullary
open import Relation.Binary.Core
open import Data.List hiding (replicate; reverse; _++_; all; map; take; drop)
open import Data.Nat
open import Data.Bool

data Nat : Set where
  Zero : Nat
  Succ  : Nat → Nat
 
add : Nat → Nat → Nat
add Zero    m = m
add (Succ n) m = Succ (add n m)

n+zero≡n : {n : Nat} → add n Zero ≡ n
n+zero≡n {Zero}   = refl
n+zero≡n {Succ x} = begin
      add (Succ x) Zero
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ (add x Zero)
    ≡⟨ cong (λ e → Succ e) (n+zero≡n {x}) ⟩ --{ 帰納法の仮定 }
      Succ x
    ∎

assoc-+ : {x y z : Nat} → add x (add y z) ≡ add (add x y) z
assoc-+ {Zero} {y} {z}   = begin
      add Zero (add y z) --{ addの定義 }
    ≡⟨ refl ⟩
      add y z
    ≡⟨ sym refl ⟩ --{ addの定義(逆方向) }
      add (add Zero y) z
    ∎
assoc-+ {Succ x} {y} {z} = begin
      add (Succ x) (add y z)
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ (add x (add y z))
    ≡⟨ cong (λ e → Succ e) (assoc-+ {x}) ⟩ --{ 帰納法の仮定 }
      Succ (add (add x y) z)
    ≡⟨ sym refl ⟩ --{ addの定義(逆方向) }
      add (Succ (add x y)) z
    ≡⟨ sym refl ⟩ --{ addの定義(逆方向) }
      add (add (Succ x) y) z
    ∎

replicate : ∀{l}{A : Set l} → ℕ → A → List A
replicate zero     _ = []
replicate (suc n) c = c ∷ (replicate n c)

replicate-length : ∀{l}{A : Set l} → {n : ℕ} → {c : A} → length (replicate n c) ≡ n
replicate-length {A = A}{n = zero} {c} = begin
      length (replicate zero c)
    ≡⟨ refl ⟩ --{ replicateの定義 }
      zero
    ∎
replicate-length {n = suc x} {c} = begin
      length (replicate (suc x) c)
    ≡⟨ refl ⟩ --{ replicateの定義 }
      length (c ∷ (replicate x c))
    ≡⟨ refl ⟩ --{ lengthの定義 }
      suc (length (replicate x c))
    ≡⟨ cong (λ e → suc e) (replicate-length {n = x}) ⟩ --{ 帰納法の仮定 }
      suc x
    ∎

_++_ : ∀{l}{A : Set l} → (xs ys : List A) → List A
[]       ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)

assoc-++ : ∀{l}{A : Set l} → {xs ys zs : List A} → (xs ++ ys) ++ zs ≡ xs ++ (ys ++ zs)
assoc-++ {xs = []}     {ys} {zs} = begin
      ([] ++ ys) ++ zs
    ≡⟨ refl ⟩ --{ ++の定義 }
      ys ++ zs
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      [] ++ (ys ++ zs)
    ∎
assoc-++ {xs = n ∷ ns} {ys} {zs} = begin
      ((n ∷ ns) ++ ys) ++ zs
    ≡⟨ refl ⟩ --{ ++の定義 }
      (n ∷ (ns ++ ys)) ++ zs
    ≡⟨ refl ⟩ --{ ++の定義 }
      n ∷ ((ns ++ ys) ++ zs)
    ≡⟨ cong (λ e → n ∷ e) (assoc-++ {xs = ns}) ⟩ --{ 帰納法の仮定 }
      n ∷ (ns ++ (ys ++ zs))
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      (n ∷ ns) ++ (ys ++ zs)
    ∎

reverse : ∀{l}{A : Set l} → List A → List A
reverse []       = []
reverse (x ∷ xs) = (reverse xs) ++ (x ∷ [])

-- right identity
rid-++ : ∀{l}{A : Set l} → {xs : List A} → xs ++ [] ≡ xs
rid-++ {xs = []}     = begin
      [] ++ []
    ≡⟨ refl ⟩ --{ ++の定義 }
      []
    ∎
rid-++ {xs = n ∷ ns} = begin
      (n ∷ ns) ++ []
    ≡⟨ refl ⟩ --{ ++の定義 }
      n ∷ (ns ++ [])
    ≡⟨ cong (λ e → n ∷ e) (rid-++ {xs = ns}) ⟩ --{ 帰納法の定義 }
      n ∷ ns
    ∎

dist-rev : ∀{l}{A : Set l} → {xs ys : List A} → reverse (xs ++ ys) ≡ reverse ys ++ reverse xs
dist-rev {xs = []} {ys}     = begin
      reverse ([] ++ ys)
    ≡⟨ refl ⟩ --{ ++の定義 }
      reverse ys
    ≡⟨ sym rid-++ ⟩ --{ xs ++ [] ≡ xs }
      reverse (ys ++ [])
    ∎
dist-rev {xs = n ∷ ns} {ys} = begin
      reverse ((n ∷ ns) ++ ys)
    ≡⟨ refl ⟩ --{ ++の定義 }
      reverse (n ∷ (ns ++ ys))
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse (ns ++ ys) ++ (n ∷ [])
    ≡⟨ cong (λ e → e ++ (n ∷ [])) (dist-rev {xs = ns}) ⟩ --{ 帰納法の仮定 }
      (reverse ys ++ reverse ns) ++ (n ∷ [])
    ≡⟨ assoc-++ {xs = reverse ys} ⟩ --{ ++の結合律 }
     reverse ys ++ (reverse ns ++ (n ∷ []))
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      reverse ys ++ reverse (n ∷ ns)
    ∎

eq-revrev : ∀{l}{A : Set l} → {xs : List A} → reverse (reverse xs) ≡ xs
eq-revrev {xs = []}     = begin
      reverse (reverse [])
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse []
    ≡⟨ refl ⟩ --{ reverseの定義 }
      []
    ∎
eq-revrev {xs = n ∷ ns} = begin
      reverse (reverse (n ∷ ns))
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse ((reverse ns) ++ (n ∷ []))
    ≡⟨ dist-rev {xs = reverse ns} ⟩ --{ reverseの分配律 }
      reverse (n ∷ []) ++ reverse (reverse ns)
    ≡⟨ cong (λ e → reverse (n ∷ []) ++ e) (eq-revrev {xs = ns}) ⟩ --{ 帰納法の仮定 }
      reverse (n ∷ []) ++ ns
    ≡⟨ refl ⟩ --{ reverseの定義 }
      (reverse [] ++ (n ∷ [])) ++ ns
    ≡⟨ refl ⟩ --{ reverseの定義 }
      ([] ++ (n ∷ [])) ++ ns
    ≡⟨ refl ⟩ --{ ++の定義 }
      (n ∷ []) ++ ns
    ≡⟨ refl ⟩ --{ ++の定義 }
      n ∷ ([] ++ ns)
    ≡⟨ refl ⟩ --{ ++の定義 }
      n ∷ ns
    ∎

reverse′ : ∀{l}{A : Set l} → List A → List A → List A
reverse′ []       ys = ys
reverse′ (x ∷ xs) ys = reverse′ xs (x ∷ ys)

rev′≡rev : ∀{l}{A : Set l} → {xs ys : List A} → reverse′ xs ys ≡ (reverse xs) ++ ys
rev′≡rev {xs = []}     {ys} = begin
      reverse′ [] ys
    ≡⟨ refl ⟩ --{ reverse′の定義 }
      ys
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      [] ++ ys
    ≡⟨ sym refl ⟩ --{ reverseの定義(逆方向) }
      (reverse []) ++ ys
    ∎
rev′≡rev {xs = n ∷ ns} {ys} = begin
      reverse′ (n ∷ ns) ys
    ≡⟨ refl ⟩ --{ reverse′の定義 }
      reverse′ ns (n ∷ ys)
    ≡⟨ rev′≡rev {xs = ns} ⟩ --{ 帰納法の仮定 }
      (reverse ns) ++ (n ∷ ys)
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      (reverse ns) ++ ([] ++ (n ∷ ys))
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      (reverse ns) ++ ((n ∷ []) ++ ys)
    ≡⟨ sym (assoc-++ {xs = reverse ns}) ⟩ --{ ++の結合律 }
      ((reverse ns) ++ (n ∷ [])) ++ ys
    ≡⟨ sym refl ⟩ --{ reverseの定義(逆方向) }
      (reverse (n ∷ ns)) ++ ys
    ∎

data Tree : Set where
  Leaf : ℕ → Tree
  Node : Tree → Tree → Tree

flatten : Tree → List ℕ
flatten (Leaf n)   = n ∷ []
flatten (Node l r) = (flatten l) ++ (flatten r)

flatten′ : Tree → List ℕ → List ℕ
flatten′ (Leaf n)   ns = n ∷ ns
flatten′ (Node l r) ns = flatten′ l (flatten′ r ns)

-- flatten′ t ns = (faltten t) ++ ns

fla′≡fla : {t : Tree} → {ns : List ℕ} → flatten′ t ns ≡ (flatten t) ++ ns
fla′≡fla {Leaf n}   {ns} = begin
      flatten′ (Leaf n) ns
    ≡⟨ refl ⟩ --{ flatten′の定義 }
      n ∷ ns
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      [] ++ (n ∷ ns)
    ≡⟨ sym refl ⟩ --{ ++の定義(逆方向) }
      (n ∷ []) ++ ns
    ≡⟨ sym refl ⟩ --{ flattenの定義(逆方向) }
      (flatten (Leaf n)) ++ ns
    ∎
fla′≡fla {Node l r} {ns} = begin
      flatten′ (Node l r) ns
    ≡⟨ refl ⟩ --{ flatten′の定義 }
      flatten′ l (flatten′ r ns)
    ≡⟨ fla′≡fla {t = l} ⟩ --{ 帰納法の仮定 }
      (flatten l) ++ (flatten′ r ns)
    ≡⟨ cong (λ e → (flatten l) ++ e) (fla′≡fla {t = r}) ⟩ --{ 帰納法の仮定 }
      (flatten l) ++ ((flatten r) ++ ns)
    ≡⟨ sym (assoc-++ {xs = flatten l}) ⟩ --{ ++の結合律 }
      ((flatten l) ++ (flatten r)) ++ ns
    ≡⟨ sym refl ⟩ --{ flattenの定義(逆方向) }
      (flatten (Node l r)) ++ ns
    ∎

-- exercise 13.9
-- 1 重複のあるパターンで定義されている標準ライブラリ関数
-- min, max, toLower, toUpper, takeWhile, dropWhile, zip

-- 2
succ-+ : {n m : Nat} → add n (Succ m) ≡ Succ (add n m)
succ-+ {Zero}   {m} = begin
      add Zero (Succ m)
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ m
    ≡⟨ sym refl ⟩ --{ addの定義(逆方向) }
      Succ (add Zero m)
    ∎
succ-+ {Succ n} {m} = begin
      add (Succ n) (Succ m)
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ (add n (Succ m))
    ≡⟨ cong (λ e → Succ e) (succ-+ {n}) ⟩ --{ 帰納法の仮定 }
      Succ (Succ (add n m))
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ (add (Succ n) m)
    ∎

-- 3
comm-+ : {n m : Nat} → add n m ≡ add m n
comm-+ {Zero}   {m} = begin
      add Zero m
    ≡⟨ refl ⟩ --{ addの定義 }
      m
    ≡⟨ sym n+zero≡n ⟩ --{ add n Zero = n }
      add m Zero
    ∎
comm-+ {Succ n} {m} = begin
      add (Succ n) m
    ≡⟨ refl ⟩ --{ addの定義 }
      Succ (add n m)
    ≡⟨ cong (λ e → Succ e) (comm-+ {n}) ⟩ --{ 帰納法の仮定 }
      Succ (add m n)
    ≡⟨ sym refl ⟩ --{ addの定義(逆方向) }
      add (Succ m) n
    ≡⟨ cong (λ e → add e n) (sym (a+1≡succ-a {m})) ⟩ --{ add a (Succ Zero) = succ a }
      add (add m (Succ Zero)) n
    ≡⟨ sym (assoc-+ {m}) ⟩ --{ addの結合律 }
      add m (add (Succ Zero) n)
    ≡⟨ refl ⟩ --{ addの定義 }
      add m (Succ (add Zero n))
    ≡⟨ refl ⟩ --{ addの定義 }
      add m (Succ n)
    ∎
   where a+1≡succ-a : {a : Nat} → add a (Succ Zero) ≡ Succ a
         a+1≡succ-a {Zero}   = begin
               add Zero (Succ Zero)
             ≡⟨ refl ⟩ --{ addの定義 }
               Succ Zero
             ∎
         a+1≡succ-a {Succ a} = begin
               add (Succ a) (Succ Zero)
             ≡⟨ refl ⟩ --{ addの定義 }
               Succ (add a (Succ Zero))
             ≡⟨ cong (λ e → Succ e) a+1≡succ-a ⟩ --{ 帰納法の仮定 }
               Succ (Succ a)
             ∎
{-
  別解、問題2で示した add a (Succ b) ≡ Succ (add a b) を用いる。
    add (Succ n) m
  ≡⟨ addの定義 ⟩
    Succ (add n m)
  ≡⟨ 帰納法の仮定 ⟩
    Succ (add m n)
  ≡⟨ 問題2 ⟩
    add n (Succ m)
  ≡⟨ 問題2 ⟩

-}

-- 4
all : ∀{l}{A : Set l} → (A → Bool) → List A → Bool
all _ []       = true
all p (x ∷ xs) = p x ∧ all p xs

{--
  replicate-eq : {n : ℕ} → ∀{l}{A : Set l} → {x : A} → all (== x) (replicate n x) ≡ true
  replicate-eq = {!!}
  一般の型に対して == のような等式は定義できないため、Agdaでの証明は略する。

  i) n = 0 のとき
     all (== x) (replicate zero x)
   ≡⟨ replicate の定義 ⟩
     all (== x) []
   ≡⟨ all の定義 ⟩
     true

  ii) n = m + 1 のとき
     all (== x) (replicate (m + 1) x)
   ≡⟨ replicate の定義 ⟩
     all (== x) (x ∷ (replicate m x))
   ≡⟨ all の定義 ⟩
     (x == x) ^ all (== x) (replicate m x)
   ≡⟨ == の反射律 ⟩
     true ^ all (== x) (replicate m x)
   ≡⟨ ^ の定義 ⟩
     all (== x) (replicate m x)
   ≡⟨ m に対する仮定 ⟩
     true
--}

-- 5 すでに証明済み
-- rid-++
-- assoc-++

-- 6
rev-lemma : ∀{l}{A : Set l} → {x : A} → {xs : List A} → reverse (xs ++ (x ∷ [])) ≡ x ∷ reverse xs
rev-lemma {x = x} {xs = []}     = begin
      reverse ([] ++ (x ∷ []))
    ≡⟨ refl ⟩ --{ ++の定義 }
      reverse (x ∷ [])
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse [] ++ (x ∷ [])
    ≡⟨ refl ⟩ --{ reverseの定義 }
      [] ++ (x ∷ [])
    ≡⟨ refl ⟩ --{ ++の定義 }
      x ∷ []
    ≡⟨ sym refl ⟩ --{ reverseの定義(逆方向) }
      x ∷ reverse []
    ∎
rev-lemma {x = x} {xs = n ∷ ns} = begin
      reverse ((n ∷ ns) ++ (x ∷ []))
    ≡⟨ refl ⟩ --{ ++の定義 }
      reverse (n ∷ (ns ++ (x ∷ [])))
    ≡⟨ refl ⟩ --{ reverseの定義 }
      (reverse (ns ++ (x ∷ []))) ++ (n ∷ [])
    ≡⟨ cong (λ e → e ++ (n ∷ [])) (rev-lemma {xs = ns}) ⟩ --{ 帰納法の仮定 }
      (x ∷ reverse ns) ++ (n ∷ [])
    ≡⟨ refl ⟩ --{ ++の定義 }
      x ∷ (reverse ns ++ (n ∷ []))
    ≡⟨ sym refl ⟩ --{ reverseの定義(逆方向) }
      x ∷ reverse (n ∷ ns)
    ∎

eq-revrev′ : ∀{l}{A : Set l} → {xs : List A} → reverse (reverse xs) ≡ xs
eq-revrev′ {xs = []}     = begin
      reverse (reverse [])
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse []
    ≡⟨ refl ⟩ --{ reverseの定義 }
      []
    ∎
eq-revrev′ {xs = n ∷ ns} = begin
      reverse (reverse (n ∷ ns))
    ≡⟨ refl ⟩ --{ reverseの定義 }
      reverse ((reverse ns) ++ (n ∷ []))
    ≡⟨ rev-lemma {xs = reverse ns} ⟩ --{ reverse (xs ++ [x]) ≡ x ∷ reverse xs }
      n ∷ (reverse (reverse ns))
    ≡⟨ cong (λ e → n ∷ e) (eq-revrev′ {xs = ns}) ⟩ --{ 帰納法の仮定 }
      n ∷ ns
    ∎

-- 7
map : ∀{l}{A B : Set l} → (f : A → B) → List A → List B
map f []       = []
map f (x ∷ xs) = f x ∷ map f xs

_∘_ : ∀{l}{A B C : Set l} → (f : B → C) → (g : A → B) → A → C
(f ∘ g) x = f (g x)

map-comp : ∀{l}{A B C : Set l} → {f : B → C} → {g : A → B} → {xs : List A} →
           map f (map g xs) ≡ map (f ∘ g) xs
map-comp {f = f} {g} {xs = []}     = begin
      map f (map g [])
    ≡⟨ refl ⟩ --{ mapの定義 }
      map f []
    ≡⟨ refl ⟩ --{ mapの定義 }
      []
    ≡⟨ sym refl ⟩ --{ mapの定義(逆方向) }
      map (f ∘ g) []
    ∎
map-comp {f = f} {g} {xs = n ∷ ns} = begin
      map f (map g (n ∷ ns))
    ≡⟨ refl ⟩ --{ mapの定義 }
      map f (g n ∷ map g ns)
    ≡⟨ refl ⟩ --{ mapの定義 }
      f (g n) ∷ map f (map g ns)
    ≡⟨ cong (λ e → f (g n) ∷ e) (map-comp {xs = ns}) ⟩ --{ 帰納法の仮定 }
      f (g n) ∷ map (f ∘ g) ns
    ≡⟨ sym refl ⟩ --{ ∘の定義(逆方向) }
      (f ∘ g) n ∷ map (f ∘ g) ns
    ≡⟨ sym refl ⟩ --{ mapの定義(逆方向) }
      map (f ∘ g) (n ∷ ns)
    ∎

-- 8
take : ∀{l}{A : Set l} → ℕ → List A → List A
take zero    _        = []
take (suc n) []       = []
take (suc n) (x ∷ xs) = x ∷ (take n xs)

drop : ∀{l}{A : Set l} → ℕ → List A → List A
drop zero    xs       = xs
drop (suc n) []       = []
drop (suc n) (x ∷ xs) = drop n xs

take-drop : ∀{l}{A : Set l} → {n : ℕ} → {xs : List A} → take n xs ++ drop n xs ≡ xs
take-drop {n = zero} {xs = []}       = begin
      take zero [] ++ drop zero []
    ≡⟨ refl ⟩ --{ takeの定義 }
      [] ++ drop zero []
    ≡⟨ refl ⟩ --{ dropの定義 }
      drop zero []
    ≡⟨ refl ⟩
      []
    ∎
take-drop {n = zero} {xs = x ∷ xs}   = begin
      take zero (x ∷ xs) ++ drop zero (x ∷ xs)
    ≡⟨ refl ⟩ --{ takeの定義 }
      [] ++ drop zero (x ∷ xs)
    ≡⟨ refl ⟩ --{ ++の定義 }
      drop zero (x ∷ xs)
    ≡⟨ refl ⟩ --{ dropの定義 }
      x ∷ xs
    ∎
take-drop {n = suc n} {xs = []}     = begin
      take (suc n) [] ++ drop (suc n) []
    ≡⟨ refl ⟩ --{ takeの定義 }
      [] ++ drop (suc n) []
    ≡⟨ refl ⟩ --{ ++の定義 }
      drop (suc n) []
    ≡⟨ refl ⟩ --{ dropの定義 }
      []
    ∎
take-drop {n = suc n} {xs = x ∷ xs} = begin
      take (suc n) (x ∷ xs) ++ drop (suc n) (x ∷ xs)
    ≡⟨ refl ⟩ --{ takeの定義 }
      (x ∷ take n xs) ++ drop (suc n) (x ∷ xs)
    ≡⟨ refl ⟩ --{ ++の定義 }
      x ∷ (take n xs ++ drop (suc n) (x ∷ xs))
    ≡⟨ refl ⟩ --{ dropの定義 }
      x ∷ (take n xs ++ drop n xs)
    ≡⟨ cong (λ e → x ∷ e) (take-drop {n = n} {xs = xs}) ⟩ --{ 帰納法の仮定 }
      x ∷ xs
    ∎

-- 9
-- ***** 整数順序の定義、定理 *************************** --
data _<=_ : Rel Nat Level.zero where
  z<=n : {n : Nat}                   → Zero   <= n
  s<=s : {m n : Nat} (m<=n : m <= n) → Succ m <= Succ n

eq→<= : {x y : Nat} → x ≡ y → x <= y
eq→<= {Zero} {Zero} refl = z<=n
eq→<= {Zero} {Succ y} ()
eq→<= {Succ x} {Zero} ()
eq→<= {Succ x} {Succ y} suc-x≡suc-y = s<=s (eq→<= x≡y)
  where ≡-suc : {a b : Nat} → Succ a ≡ Succ b → a ≡ b
        ≡-suc refl = refl
        x≡y : x ≡ y
        x≡y = ≡-suc suc-x≡suc-y

<=trans : {x y z : Nat} → x <= y → y <= z → x <= z
<=trans {Zero}  {_}     {z}      x<=y         y<=z = z<=n
<=trans {Succ x}{Zero}  {z}      ()
<=trans {Succ x}{Succ y}{Zero}   suc-x<=suc-y ()
<=trans {Succ x}{Succ y}{Succ z} (s<=s x<=y) (s<=s y<=z) = s<=s (<=trans x<=y y<=z)

<=+n : {a b : Nat} → a <= add a b
<=+n {Zero}   = z<=n
<=+n {Succ a} = s<=s (<=+n {a})

a+c<=b+d : {a b c d : Nat} → a <= b → c <= d → add a c <= add b d
a+c<=b+d {Zero}  {b}     {c}     {d}      z<=n        c<=d        = <=trans p1 p2
  where p1 : c <= add d b
        p1 = <=trans (c<=d) (<=+n)
        p2 : add d b <= add b d
        p2 = eq→<= (comm-+ {d})
a+c<=b+d {Succ a}{Zero}                   ()
a+c<=b+d {Succ a}{Succ b}{Zero}  {d}      (s<=s a<=b) z<=n        = s<=s (<=trans p2 p1)
  where p1 : a <= add b d
        p1 = <=trans a<=b <=+n
        p2 : add a Zero <= a
        p2 = eq→<= n+zero≡n
a+c<=b+d {Succ a}{Succ b}{Succ c}{Zero}   _           ()
a+c<=b+d {Succ a}{Succ b}{Succ c}{Succ d} (s<=s a<=b) (s<=s c<=d) = s<=s p4
  where p1 : add a c <= add b d
        p1 = a+c<=b+d a<=b c<=d
        p2 : add a (Succ c) <= Succ (add a c)
        p2 = eq→<= (succ-+ {a})
        p3 : Succ (add b d) <= add b (Succ d)
        p3 = eq→<= (sym (succ-+ {b}))
        p4 : add a (Succ c) <= add b (Succ d)
        p4 = <=trans p2 (<=trans (s<=s p1) p3)
-- ****************************************************** --

cnt-leaf : Tree → Nat
cnt-leaf (Leaf _)   = Succ Zero
cnt-leaf (Node l r) = add (cnt-leaf l) (cnt-leaf r)

cnt-node : Tree → Nat
cnt-node (Leaf _)   = Zero
cnt-node (Node l r) = Succ (add (cnt-node l) (cnt-node r))

tree-lemm : {t : Tree} → Succ (cnt-node t) <= cnt-leaf t
tree-lemm {Leaf n}   = eq→<= p
  where p : Succ (cnt-node (Leaf n)) ≡ cnt-leaf (Leaf n)
        p = begin
           Succ (cnt-node (Leaf n))
         ≡⟨ refl ⟩ --{ cnt-nodeの定義 }
           Succ Zero
         ≡⟨ sym refl ⟩ --{ cnt-leafの定義(逆方向) }
           cnt-leaf (Leaf n)
         ∎
tree-lemm {Node l r} = <=trans p4 p3
  where for-l : Succ (cnt-node l) <= cnt-leaf l
        for-l = tree-lemm {l}
        for-r : Succ (cnt-node r) <= cnt-leaf r
        for-r = tree-lemm {r}
        p1 : add (Succ (cnt-node l)) (Succ (cnt-node r)) <= add (cnt-leaf l) (cnt-leaf r)
        p1 = a+c<=b+d for-l for-r
        p2 : add (Succ (cnt-node l)) (Succ (cnt-node r)) ≡ Succ (add (Succ (cnt-node l)) (cnt-node r))
        p2 = succ-+ {(Succ (cnt-node l))}
        p3 : Succ (add (Succ (cnt-node l)) (cnt-node r)) <= add (cnt-leaf l) (cnt-leaf r)
        p3 = <=trans (eq→<= (sym p2)) p1
        p4 : Succ (cnt-node (Node l r)) <= Succ (add (Succ (cnt-node l)) (cnt-node r))
        p4 = eq→<= refl

-- 10
-- これから

-- cong (λ∎
-- ∎
-- ℕ
-- assoc-+   add x (add y z) ≡ add (add x y) z

