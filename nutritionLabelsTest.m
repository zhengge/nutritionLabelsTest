%function temp=nutritionLabelsTest(testImage)
    clear;
    testImage = imread('D:\Users\sony\Desktop\nutritionLabelsTest\���ݿ�\simple\simple\normal\2.jpg');
%     figure,imshow(testImage),title('���ɫͼ��');
    testImageGray = rgb2gray(testImage);%������ͼ��ת��Ϊ�Ҷ�ͼ��
%     subplot(2,3,1),imshow(testImageGray),title('�Ҷ�ͼ��');

    %��򷨶�ֵ��
    level = graythresh(testImageGray);
    testImageBinaryzation = im2bw(testImageGray, level); %��ֵ����ֵ����
%     subplot(2,3,2),imshow(testImageBinaryzation),title('��ֵ��ͼ��ͼ��');

    %canny���Ӽ���Ե
    testImageCanny=edge(testImageGray,'canny');
%     subplot(2,5,3),imshow(testImageCanny),title('��Եͼ��');

    %hough�任
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
    lenghtLineCnt = lenghtLineNum;%��hough�߶ε���������ѭ������
    %ʹ�ò�����һ���Ƕȵ���߶ν���hough����
    while lenghtLineCnt>0
        ratio=-(lines(PositionLine(lenghtLineCnt)).point1(2)-lines(PositionLine(lenghtLineCnt)).point2(2))/...
            (lines(PositionLine(lenghtLineCnt)).point1(1)-lines(PositionLine(lenghtLineCnt)).point2(1));
        angle = atan(ratio)*180/pi;
        if angle<=20 && angle>=-20 %�Ƕ�С��һ��ֵʱ��������������������
            %�߶ε���ʼ����ֹ��
            x=[lines(PositionLine(lenghtLineCnt)).point1(1),lines(PositionLine(lenghtLineCnt)).point2(1)];
            y=[lines(PositionLine(lenghtLineCnt)).point1(2),lines(PositionLine(lenghtLineCnt)).point2(2)];
            % ǿ�����ڽ������߶εĲ���
%             plot(x',y','LineWidth',2,'Color','blue');
            lenghtLineCnt=0;
        end
        lenghtLineCnt=lenghtLineCnt-1;
    end

    %ɾ�����Ե���ͨ����
    [testImageRows,testImagecolumns] = size(testImageBinaryzation);%testImageBinaryzationd�ĳ���
    for j=1:2, %��������ɾ����ɾ��һЩ�ϴֵ�ֱ��
        [B,L] = bwboundaries(testImageBinaryzation);%������ͨ��
        for k=1:length(B),
            c = B(k,:);
            d = c{1,1};
            max_y = max(d(:,1));
            min_y = min(d(:,1));
            max_x = max(d(:,2));
            min_x = min(d(:,2));
            if (max_y-min_y)>50 || (max_x-min_x)>50 || (double(max_y-min_y)/double(max_x-min_x))>20 || ...
                    (double(max_x-min_x)/double(max_y-min_y))>20,  %��ͨ���г����ϳ���Ϊ�߿�Ӧȥ��,��������ϴ��Ҳ��ɾ��
                for i=1:size(d,1)  %��һ����ͨ�������еĵ㣬�Լ�������������Ϊ1������ɫ
                    testImageBinaryzation(d(i,1),d(i,2)) = 1;
                    if (d(i,1)+1)<=testImageRows  %��ֹ����ͼ��߽�
                        testImageBinaryzation((d(i,1)+1),d(i,2)) = 1;
                    end
                    if (d(i,1)-1)>=1 %��ֹ����ͼ��߽�
                        testImageBinaryzation((d(i,1)-1),d(i,2)) = 1;
                    end
                    if (d(i,2)-1)>=1 %��ֹ����ͼ��߽�
                        testImageBinaryzation(d(i,1),(d(i,2)-1)) = 1;
                    end
                    if (d(i,2)+1)<=testImagecolumns %��ֹ����ͼ��߽�
                        testImageBinaryzation(d(i,1),(d(i,2)+1)) = 1;
                    end
                end
            end
        end
    end
    testImageDeleteLine = testImageBinaryzation;
%     subplot(2,3,4),imshow(testImageDeleteLine),title('ɾ�����ߺ��ͼ��');
    %��ɾ���߿��ͼƬ����hough����
    testImageHough = imrotate(testImageDeleteLine,-angle,'bilinear','crop');% imrate ����ʱ�������ȡһ������
%     subplot(2,3,5),imshow(testImageHough);title('Hough����ͼ��');
    
    %��hough�������ͼƬ������ͨ��Ĵ���
    [B,L,N] = bwboundaries(testImageHough);
    figure; imshow(testImageHough); hold on;
    SingleWordParametersCnt = 1;
    %�õ����е�������ͨ�����SingleWordParameters
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
            if wide>=5 || height>=10  %��ȥ��С����ͨ��
                rectangle('Position',[min_x,min_y,wide,height],'EdgeColor','r');
                center_x = (min_x+max_x)/2;
                center_y = (min_y+max_y)/2;
                SingleWordParameters(SingleWordParametersCnt,:) = [min_x min_y max_x max_y center_x center_y wide height];
                SingleWordParametersCnt=SingleWordParametersCnt+1;
            end
        end
    end
    SingleWordParametersCnt=1;
    %�õ�����ͬ������ͨ�����LineWordParameters
    LineWordParametersNum=1;
    while size(SingleWordParameters,1)>0
%         figure; imshow(testImageHough); hold on;
        LineWordParametersCnt=1;
        min_center_y = min(SingleWordParameters(:,6));
        for m=1:size(SingleWordParameters,1)
            if (SingleWordParameters(m,6)-min_center_y)<=10
                rectangle('Position',[SingleWordParameters(m,1),SingleWordParameters(m,2),...
                    SingleWordParameters(m,7),SingleWordParameters(m,8)],'EdgeColor','b');
                LineWordParameters(LineWordParametersNum,LineWordParametersCnt,:)=[SingleWordParameters(m,:),m];
                LineWordParametersCnt=LineWordParametersCnt+1;
            end
        end
        %ɾ���Ѿ���λ����ͨ��
        for n=1:(LineWordParametersCnt-1)
            if (LineWordParameters(LineWordParametersNum,n,9)-n+1)>=1
                SingleWordParameters(LineWordParameters(LineWordParametersNum,n,9)-n+1,:)=[];
            else%���ڵ�һλʱ
                SingleWordParameters(1,:)=[];
            end
        end
        LineWordParametersNum=LineWordParametersNum+1;
    end
    %����һ�еĲ���
    LineWordParameters(find(LineWordParameters==0))=NaN;%ɾ��LineWordParameters��Ϊ0�����ݣ���������Ѱ����Сֵ
    for i=1:size(LineWordParameters,1)
        lineParameters(i,:)=[min(LineWordParameters(i,:,1)),min(LineWordParameters(i,:,2)),...
            max(LineWordParameters(i,:,3)),max(LineWordParameters(i,:,4))];
        rectangle('Position',[lineParameters(i,1),lineParameters(i,2),lineParameters(i,3)-lineParameters(i,1),...
                    lineParameters(i,4)-lineParameters(i,2)],'EdgeColor','r');
    end
    
    temp=testImageHough;
%end 