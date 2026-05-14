-- module Assignment_5 where

-- | A simple polymorphic Min Heap
data MinHeap a = Empty | Node a (MinHeap a) (MinHeap a)
    deriving (Show, Eq)


-- | Check whether the heap is empty.
--
-- >>> isEmpty Empty
-- True
--
-- >>> isEmpty (Node 5 Empty Empty)
-- False
--
isEmpty :: MinHeap a -> Bool
isEmpty Empty = True
isEmpty (Node x _ _) = False



-- | Compute the total number of elements in the heap.
--
-- >>> size Empty
-- 0
--
-- >>> size (Node 5 (Node 3 Empty Empty) Empty)
-- 2
--
-- >>> size (Node 5 (Empty) Empty)
-- 1
--
size :: MinHeap a -> Int
size Empty = 0
size (Node _ l r) = 1 + (size l) + (size r)


-- | Return the minimum element (root) of the heap.
--   Assume the heap is not empty.
--
-- >>> findMin (Node 2 Empty Empty)
-- 2
--
-- >>> findMin (Node 1 (Node 3 Empty Empty) Empty)
-- 1
--
findMin :: MinHeap a -> a
findMin Empty = error "Heap is empty"
findMin (Node x _ _) = x


-- | Convert the heap into a list using preorder traversal.
--
-- >>> heapToList (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- [1,2,3]
--
heapToList :: MinHeap a -> [a]
heapToList Empty = []
heapToList (Node x l r) = [x] ++ (heapToList l) ++ (heapToList r)


-- | Check whether a heap satisfies the min-heap property.
--   A node must be less than or equal to its children.
--
-- >>> isHeap (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- True
--
-- >>> isHeap (Node 5 (Node 2 Empty Empty) Empty)
-- False
--
isHeap :: Ord a => MinHeap a -> Bool
isHeap Empty = True
isHeap (Node x Empty Empty) = True
isHeap (Node x left@(Node y _ _) Empty) = 
    x <= y && isHeap left
isHeap (Node x Empty right@(Node y _ _)) = 
    x <= y && isHeap right
isHeap (Node x left@(Node y _ _) right@(Node z _ _)) = 
    x <= y && x <= z && isHeap left && isHeap right


-- | Helper function to merge two heaps.
merge :: Ord a => MinHeap a -> MinHeap a -> MinHeap a
merge h1 Empty = h1
merge Empty h2 = h2
merge h1@(Node x1 l1 r1) h2@(Node x2 l2 r2)
    | x1 <= x2 = Node x1 (merge r1 h2) l1
    | otherwise = Node x2 (merge r2 h1) l2


-- | Insert an element into the heap while maintaining heap property.
--
-- >>> insertHeap 2 (Node 5 Empty Empty)
-- Node 2 (Node 5 Empty Empty) Empty
--
insertHeap :: Ord a => a -> MinHeap a -> MinHeap a
insertHeap x h = merge (Node x Empty Empty) h


-- | Delete the minimum element (root) from the heap.
--
-- >>> deleteMin (Node 1 (Node 2 Empty Empty) (Node 3 Empty Empty))
-- Node 2 (Node 3 Empty Empty) Empty
--

deleteMin :: Ord a => MinHeap a -> MinHeap a
deleteMin Empty = error "Heap is empty"
deleteMin (Node _ l r) = merge l r


-- | Return all even elements from the heap using list comprehension.
--
-- >>> evenHeap (Node 1 (Node 2 Empty Empty) (Node 4 Empty Empty))
-- [2,4]
--
evenHeap :: MinHeap Int -> [Int]
evenHeap h = [x | x <- (heapToList h), even x]


-- | Apply a function to every element in the heap.
--
-- >>> mapHeap (*2) (Node 1 Empty Empty)
-- Node 2 Empty Empty
--

-- >>> mapHeap (*2) (Node 1 (Node 4 Empty Empty) Empty)
-- Node 2 (Node 8 Empty Empty) Empty
--
mapHeap :: (a -> a) -> MinHeap a -> MinHeap a
mapHeap f Empty = Empty
mapHeap f (Node x l r) = Node (f x) (mapHeap f l) (mapHeap f r)


-- | Process the heap by extracting even elements and squaring them.
--
-- >>> processHeap (Node 2 (Node 3 Empty Empty) (Node 4 Empty Empty))
-- [4,16]
--
processHeap :: MinHeap Int -> [Int]
processHeap h = map (^2) (evenHeap h)


-- | Interactive program:
--   Reads numbers, builds heap, and prints results
--
main :: IO ()
main = do
    putStrLn "--- MinHeap Interactive Program ---"
    putStrLn "Enter a list of integers separated by spaces (e.g., 5 2 8 1 3):"
    
    -- 1. Read the input line from the user
    input <- getLine
    
    -- 2. Convert the input string into a list of Integers
    -- words splits "1 2 3" into ["1", "2", "3"]
    -- map read converts strings to actual numbers
    let numbers = map read (words input) :: [Int]
    
    -- 3. Build the heap by starting with Empty and inserting each number
    -- foldl is like a loop that carries the 'acc' (the heap) forward
    let myHeap = foldl (\acc x -> insertHeap x acc) Empty numbers
    
    -- 4. Display the results using the functions you wrote
    putStrLn "\n[Results]"
    putStrLn $ "Final MinHeap structure: " ++ show myHeap
    putStrLn $ "Total elements (size): " ++ show (size myHeap)
    putStrLn $ "Min element (findMin): " ++ show (findMin myHeap)
    putStrLn $ "Preorder list: " ++ show (heapToList myHeap)
    putStrLn $ "Processed even squares: " ++ show (processHeap myHeap)
    
    putStrLn "\nCheck if it satisfies Min-Heap property:"
    putStrLn $ if isHeap myHeap then "Yes, it is a valid Min-Heap." else "No, heap property violated."
