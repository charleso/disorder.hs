module Disorder.Core.Gen (
    vectorOfSize
  , chooseSize
  , maybeGen
  , genFromMaybe
  , smaller
  , listOfSized
  -- * re-exports from quickcheck-text
  , genValidUtf8
  , genValidUtf81
  , utf8BS
  , utf8BS1
  ) where

import           Control.Applicative

import           Data.Maybe (isJust)

import           Test.QuickCheck.Gen
import           Test.QuickCheck.Utf8

import           Prelude

-- | Return a vector whose size is within the provided bounds
vectorOfSize :: Int -> Int -> Gen a -> Gen [a]
vectorOfSize min' max' gen =
  chooseSize min' max' >>= flip vectorOf gen

-- | Return an 'Int' which is between the provided range, and influenced by the current "size"
chooseSize :: Int -> Int -> Gen Int
chooseSize min' max' =
  sized (return . min max' . max min')

-- | from a generator return a generator that will generate Nothing sometimes
maybeGen :: Gen a -> Gen (Maybe a)
maybeGen g = sized $ \s ->
  frequency [
    (1, return Nothing),
    (s, Just <$> resize (s `div` 2) g)]

-- | Wait for a generated `Just` value
--
-- Use _only_ in case of emergencies when you have no other way to get an `a` safely
genFromMaybe :: Gen (Maybe a) -> Gen a
genFromMaybe g =
  suchThat g isJust >>= \ma ->
    case ma of
      Just a -> pure a
      Nothing -> fail "Disorder.Core.Gen.genFromMaybe: Failed to generate a Just"

-- | Generate something smaller
smaller :: Gen a -> Gen a
smaller g =
  sized $ \s -> resize (s `div` 2) g

-- | Generate a list this big.
listOfSized :: Gen a -> Int -> Gen [a]
listOfSized gen n = take n <$> infiniteListOf gen
