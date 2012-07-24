/*
	Created by Timo Rantalainen
*/

package javaLoop;

import java.util.PriorityQueue;

public class RegionGrow{
	
	public double[][]	grown;	//Grown region mask
	
	/*Parameters*/
	private double[][] dataSlice;
	private double[][] segmentationMask;
	private double maxDiff;
	
	/*Global variables, saves effort in declaring functions...*/
	private int rowCount;
	private int columnCount;
	private byte[][] visited;
	private double currentMean;
	private PriorityQueue<NextPixel> pixelQueue;
	/*Constructor for default maxDiff*/
	public RegionGrow(double[][] dataSlice, double[][] segmentationMask){
		this.dataSlice = dataSlice;
		this.segmentationMask = segmentationMask;
		this.maxDiff = 250.0;
		growRegion();
	}
	
	/*Constructor with maxDiff*/
	public RegionGrow(double[][] dataSlice, double[][] segmentationMask, double maxDiff){
		this.dataSlice = dataSlice;
		this.segmentationMask = segmentationMask;
		this.maxDiff = maxDiff;
		growRegion();
	}
	
	private void growRegion(){
		/*Init variables and add seed points to the queue*/
		pixelQueue = new PriorityQueue<NextPixel>();
		rowCount = dataSlice.length;
		columnCount = dataSlice[0].length;
		visited = new byte[rowCount][columnCount];
		currentMean = getCurrentMean();
		/*Init pixelQueue*/
		int[][] seedIndices = find(segmentationMask);
		for (int i = 0; i<seedIndices.length; ++i){
			int[] coordinates = {seedIndices[i][0],seedIndices[i][1]};
			pixelQueue.add(new NextPixel(Math.abs(dataSlice[seedIndices[i][0]][seedIndices[i][1]]-currentMean),coordinates));
		}
		
	}
	
	private int[][] find(double[][] matrix){
		int[][] temp = new int[matrix.length*matrix[0].length][2];
		int found = 0;
		for (int i = 0; i< matrix.length;++i){
			for (int j = 0; j< matrix[i].length;++j){
				if (matrix[i][j] > 0){
					temp[found][0] = i;
					temp[found][1] = j;
					++found;					
				}
			}
		}
		int[][] indices = new int[found][2];
		for (int i = 0; i<found; ++i){
			for (int j = 0; j< 2; ++j){
				indices[i][j] = temp[i][j];
			}
		}
		return indices;
	}
	
	private double getCurrentMean(){
		int[][] indices = find(segmentationMask);
		double sum = 0;
		for (int i = 0; i<indices.length; ++i){
			sum+= dataSlice[indices[i][0]][indices[i][1]];
		}
		sum/=(double) indices.length;
		return sum;
	}
	


   /*Next Pixel for pixel queue, comparable enables always getting the smallest value*/
	class NextPixel implements Comparable<NextPixel> {
		public int[] coordinates;
		public double cost;
		public NextPixel(double cost, int[] coordinates){
			this.cost =cost;
			this.coordinates = coordinates;
		}

		public int compareTo(NextPixel other){
			if( cost < other.cost){
				return -1;
			}else{ 
				if( cost > other.cost){ 
					return +1;
				}else{
					return 0;
				}
			}
		}

	}	    	

}








