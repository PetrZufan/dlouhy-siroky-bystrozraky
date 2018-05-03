
glovesneeded.

+step(0) <- .println("START");?grid_size(A,B);+right(A);+down(B);+right;do(skip);do(skip).


+step(X): gloves(A,B)&pos(A,B)&glovesneeded<--glovesneeded;do(pick).
 
+step(X):carrying_capacity(Y)&carrying_wood(Z)<-.println("Unesu ",Y,", nesu ",Z);!go.

 +!go:pos(A,B)&wood(A,B)<-do(pick).

 +!go: right & pos(A,B) & right(C)&A<C-1<- do(right);do(skip).
 +!go: right <- -right;+left;do(down);do(skip).	
 +!go: left & pos(A,B) & A>0 <- do(left);do(skip).	
 +!go: left<-  -left;+right;do(down);do(skip).



