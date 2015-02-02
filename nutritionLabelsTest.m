%function temp=nutritionLabelsTest(testImage)
    testImage = imread('D:\Users\sony\Desktop\营养标签识别\数据库\simple\simple\normal\2.jpg');
%     figure,imshow(testImage),title('真彩色图像');
    testImageGray = rgb2gray(testImage);%将索引图像转换为灰度图像
%     subplot(2,3,1),imshow(testImageGray),title('灰度图像');

    %大津法二值化
    level = graythresh(testImageGray);
    testImageBinaryzation = im2bw(testImageGray, level); %二值化阈值待定
%     subplot(2,3,2),imshow(testImageBinaryzation),title('二值化图像图像');

    %canny算子检测边缘
    testImageCanny=edge(testImageGray,'canny');
%     subplot(2,5,3),imshow(testImageCanny),title('边缘图像');

    %hough变换
    [H, theta, rho]= hough(testImageCanny,'RhoResolution',1,'Theta',-90:0.5:89.5);
    peak=houghpeaks(H,5);
    lines=houghlines(testImageCanny,theta,rho,peak);
%     subplot(2,3,3),imshow(testImageCanny,[]),title('Hough Transform Detect Result'),hold on;
    for k=1:length(lines)
        xy=[lines(k).point1;lines(k).point2];
%         plot(xy(:,1),xy(:,2),'LineWidth',4,'Color',[.6 .6 .6]);    
        len=norm(lines(k).point1-lines(k).point2);
        LenghtLine(k)=len;
    end 
    [lenghtLineSort,PositionLine] = sort(LenghtLine(:));
    lenghtLineNum = size(lenghtLineSort,1);
    lenghtLineCnt = lenghtLineNum;%将hough线段的数量赋给循环变量
    %使用不超过一定角度的最长线段进行hough矫正
    while lenghtLineCnt>0
        ratio=-(lines(PositionLine(lenghtLineCnt)).point1(2)-lines(PositionLine(lenghtLineCnt)).point2(2))/(lines(PositionLine(lenghtLineCnt)).point1(1)-lines(PositionLine(lenghtLineCnt)).point2(1));
        angle = atan(ratio)*180/pi;
        if angle<=20 && angle>=-20 %角度小于一定值时，矫正，其他区情况误检
            %线段的起始和终止点
            x=[lines(PositionLine(lenghtLineCnt)).point1(1),lines(PositionLine(lenghtLineCnt)).point2(1)];
            y=[lines(PositionLine(lenghtLineCnt)).point1(2),lines(PositionLine(lenghtLineCnt)).point2(2)];
            % 强调用于矫正的线段的部分
%             plot(x',y','LineWidth',2,'Color','blue');
            lenghtLineCnt=0;
        end
        lenghtLineCnt=lenghtLineCnt-1;
    end

    %删除不对的连通区域
    [testImageRows,testImagecolumns] = size(testImageBinaryzation);%testImageBinaryzationd的长宽
    for j=1:2, %进行两次删除，删除一些较粗的直线
        [B,L] = bwboundaries(testImageBinaryzation);%计算连通域
        for k=1:length(B),
            c = B(k,:);
            d = c{1,1};
            max_y = max(d(:,1));
            min_y = min(d(:,1));
            max_x = max(d(:,2));
            min_x = min(d(:,2));
            if (max_y-min_y)>50 || (max_x-min_x)>50 || (double(max_y-min_y)/double(max_x-min_x))>20 || (double(max_x-min_x)/double(max_y-min_y))>20,  %连通域中长或宽较长的为边框应去掉,长宽比例较大的也因删除
                for i=1:size(d,1)  %将一个连通域内所有的点，以及它的四领域置为1，及白色
                    testImageBinaryzation(d(i,1),d(i,2)) = 1;
                    if (d(i,1)+1)<=testImageRows  %防止超出图像边界
                        testImageBinaryzation((d(i,1)+1),d(i,2)) = 1;
                    end
                    if (d(i,1)-1)>=1 %防止超出图像边界
                        testImageBinaryzation((d(i,1)-1),d(i,2)) = 1;
                    end
                    if (d(i,2)-1)>=1 %防止超出图像边界
                        testImageBinaryzation(d(i,1),(d(i,2)-1)) = 1;
                    end
                    if (d(i,2)+1)<=testImagecolumns %防止超出图像边界
                        testImageBinaryzation(d(i,1),(d(i,2)+1)) = 1;
                    end
                end
            end
        end
    end
    testImageDeleteLine = testImageBinaryzation;
%     subplot(2,3,4),imshow(testImageDeleteLine),title('删除横线后的图像');
    %对删除边框的图片进行hough矫正
    testImageHough = imrotate(testImageDeleteLine,-angle,'bilinear','crop');% imrate 是逆时针的所以取一个负号
%     subplot(2,3,5),imshow(testImageHough);title('Hough矫正图形');
    
    %对hough矫正后的图片进行连通域的处理
    [B,L,N] = bwboundaries(testImageHough);
    figure; imshow(testImageHough); hold on;
%     connectedDomainParameters(1,:)=[1 2 3 4]
%     connectedDomainParameters(1,:)=[1 2 3 4]
    connectedDomainParametersCnt = 1;
    for k=1:length(B),
        boundary = B{k};
        if(k > N)
            c = B(k,:);
            d = c{1,1};
            max_y = max(d(:,1));
            min_y = min(d(:,1));
            max_x = max(d(:,2));
            min_x = min(d(:,2));
            wide = max_x-min_x;
            height = max_y-min_y;
%             rectangle('Position',[10,10,100,100]);
            if wide>=5 || height>=5  %除去较小的连通域
                rectangle('Position',[min_x,min_y,wide,height],'EdgeColor','r');
                connectedDomainParameters(connectedDomainParametersCnt,:) = [min_x min_y max_x max_y wide height];
                connectedDomainParametersCnt=connectedDomainParametersCnt+1;
            end
%         else
%             plot(boundary(:,2),...
%                 boundary(:,1),'r','LineWidth',2);
        end
    end
    connectedDomainParametersCnt=0;


    temp=testImageHough;
%end 