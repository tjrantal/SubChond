package javaLoop;
public class JavaLoop{
	/*
	public double[][] wholeImageVarHist;
	public double[][] wholeImageLBP;
	public double[][] data;
	public 	double[] varCutPoints;
	public double[] lbpCutPoints;
	public double[] grayBinCutpoints;
	public int lbpBlockSize;
	public double[] varianceSumHistogram;
	public double[] lbpSumHistogram;
	public double[] graySumHistogram;
	*/
	public double[][] vCloseness;
	public double[][] lCloseness;
	public double[][] gCloseness;
	public double[][] mask;
	//public double[][][] histograms;
	//public double[] histo;
	
	public JavaLoop(double[][] wholeImageVarHist, double[][] wholeImageLBP, double[][] data, double[] varCutPoints, double[] lbpCutPoints, double[] grayBinCutpoints, int lbpBlockSize, double[] varianceSumHistogram,double[] lbpSumHistogram,double[] graySumHistogram){
		//System.out.println("data 1 1 "+data[1][1]+" data 1 2 "+data[1][2]+" data 2 1 "+data[2][1]);
		vCloseness = new double[wholeImageVarHist.length-lbpBlockSize][wholeImageVarHist[0].length-lbpBlockSize];
		lCloseness = new double[wholeImageVarHist.length-lbpBlockSize][wholeImageVarHist[0].length-lbpBlockSize];
		gCloseness = new double[wholeImageVarHist.length-lbpBlockSize][wholeImageVarHist[0].length-lbpBlockSize];
		mask = new double[wholeImageVarHist.length-lbpBlockSize][wholeImageVarHist[0].length-lbpBlockSize];
		//histograms = new double[wholeImageVarHist.length-lbpBlockSize][wholeImageVarHist[0].length-lbpBlockSize][];
		/*
		int r = 0;
		int c = 0;
		*/
		for (int r = 0;r<wholeImageVarHist.length-lbpBlockSize;++r){
            for (int c = 0; c<wholeImageVarHist[r].length-lbpBlockSize;++c){
			
                double[] varHist = histc(reshape(wholeImageVarHist,r,r+lbpBlockSize,c,c+lbpBlockSize),varCutPoints);
				
                double[] lbpHist = histc(reshape(wholeImageLBP,r,r+lbpBlockSize,c,c+lbpBlockSize),lbpCutPoints);
                double[] grayHist = histc(reshape(data,r,r+lbpBlockSize,c,c+lbpBlockSize),grayBinCutpoints);
				
				//histograms[r][c] = varHist;
				//histo = varHist;
                varHist = arrDiv(varHist,sum(varHist));
				
                lbpHist = arrDiv(lbpHist,sum(lbpHist));
                grayHist = arrDiv(grayHist,sum(grayHist));
				
				
				
                vCloseness[r][c] = checkClose(varHist,varianceSumHistogram);
                lCloseness[r][c] = checkClose(lbpHist,lbpSumHistogram);
                gCloseness[r][c] = checkClose(grayHist,graySumHistogram);
                if (vCloseness[r][c]+lCloseness[r][c]+gCloseness[r][c] > 1.9){
					mask[r][c]=1;
                }else{
					mask[r][c]=0;
                }
				
           }
        }
		
	}
	private double[] histc(double[] values,double[] cutPoints){
		double[] histogram = new double[cutPoints.length];
		for (int i = 0;i<values.length;++i){
			int j = 0;
			
			//while (j < cutPoints.length-1 && values[i] <cutPoints[j+1]){++j;}
			while (j < cutPoints.length-2 && values[i] >= cutPoints[j+1]){
				++j;
			}
			if (values[i] == cutPoints[cutPoints.length-1]){
				j = j+1;
			}
			//System.out.println("ind "+i+ " val "+values[i]+" bin "+j+" from "+cutPoints[j]);
			histogram[j] += 1;
		}
		
		return histogram;
	}
	private double[] reshape(double[][] dataIn,int xb,int xe,int yb,int ye){
		double[] array = new double[(xe-xb+1)*(ye-yb+1)];
		int ind = 0;
		for (int y = yb;y<=ye;++y){
			for (int x = xb;x<=xe;++x){
				array[ind] = dataIn[x][y];
				++ind;
			}
		}
		return array;
	}
	private double sum(double[] arrayIn){
		double temp = 0;
		for (int i = 0;i< arrayIn.length;++i){
			temp+=arrayIn[i];
		}
		return temp;
	}
	private double[] arrDiv(double[] arrayIn,double divisor){
		for (int i = 0;i< arrayIn.length;++i){
			arrayIn[i]/=divisor;
		}
		return arrayIn;
	}
	
	public double checkClose(double[] sampleHist,double[] modelHist){
        double closeness = 0;
        for (int h = 0;h<sampleHist.length;++h){
            closeness += min(sampleHist[h],modelHist[h]);
        }
		return closeness;
    }
	private double min(double a, double b){
		return (a < b) ? a : b;
	}
}