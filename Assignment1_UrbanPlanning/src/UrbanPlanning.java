import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;


public class UrbanPlanning {
	private static int rows = 5;
	private static int cols = 5;
	private static int comLotValue = 1;
	private static int resLotValue = 0;
	private static int nbrOfComLots = comLotValue*13;
	
	public static void main(String args[]) {
		plan();
	}
	
	static void plan() {
		// 0 = residential lot, 1 = commercial lot
		Store store = new Store();

		IntVar[] grid = new IntVar[rows*cols];
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				grid[i*rows + j] = new IntVar(store,"(" + i + "," + j + ")",resLotValue,comLotValue);
			}
		}
		IntVar sum = new IntVar(store,"sum",nbrOfComLots,nbrOfComLots);
		store.impose(new Sum(grid, sum));
		
		IntVar fives = new IntVar(store, "fives", 0, 10);
		IntVar fours = new IntVar(store, "fours", 0, 10);
		IntVar threes = new IntVar(store, "threes", 0, 10);
		IntVar mFives = new IntVar(store, "mFives", 0, 10);
		IntVar mFours = new IntVar(store, "mFours", 0, 10);
		IntVar mThrees = new IntVar(store, "mThrees", 0, 10);
				
		IntVar cost = new IntVar(store, "cost", -50, 50);
		IntVar[] resInRows = new IntVar[10];
		IntVar[] comInRows = new IntVar[10];
		for (int i = 0; i < rows; i++) {

			IntVar[] row = new IntVar[rows];
			IntVar[] col = new IntVar[rows];
			for (int j = 0; j < row.length; j++) {
				row[j] = grid[i*rows + j];
				col[j] = grid[i + rows*j];
			}
			
			resInRows[i] = new IntVar(store, "resInRow" + i, 0, 5);
			store.impose(new Count(row, resInRows[i], 0));
			comInRows[i] = new IntVar(store, "comInRow" + i, 0, 5);
			store.impose(new Count(row, comInRows[i], 1));
			
			resInRows[i+rows] = new IntVar(store, "resInRow" + (i+rows), 0, 5);
			store.impose(new Count(col, resInRows[i+rows], 0));
			comInRows[i+rows] = new IntVar(store, "comInRow" + (i+rows), 0, 5);
			store.impose(new Count(col, comInRows[i+rows], 1));			

		}


		store.impose(new Count(resInRows, fives, 5));
		store.impose(new Count(resInRows, fours, 4));
		store.impose(new Count(resInRows, threes, 3));
		store.impose(new Count(comInRows, mFives, 5));
		store.impose(new Count(comInRows, mFours, 4));
		store.impose(new Count(comInRows, mThrees, 3));
		IntVar[] nums = new IntVar[] {fives,fours,threes,mFives,mFours,mThrees};
		int[] numWeights = new int[] {-5,-4,-3,5,4,3};
		store.impose(new SumWeight(nums, numWeights, cost));
		

		
		Search<IntVar> search = new DepthFirstSearch<IntVar>();
		SelectChoicePoint <IntVar> select = new InputOrderSelect <IntVar>(store, grid, new IndomainMin<IntVar>());
		search.labeling(store, select, cost);

		
	}
}
