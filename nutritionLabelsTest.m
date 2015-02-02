%function temp=nutritionLabelsTest(testImage)
    testImage = imread('D:\Users\sony\Desktop\Ӫ����ǩʶ��\���ݿ�\simple\simple\normal\2.jpg');
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
        ratio=-(lines(PositionLine(lenghtLineCnt)).point1(2)-lines(PositionLine(lenghtLineCnt)).point2(2))/(lines(PositionLine(lenghtLineCnt)).point1(1)-lines(PositionLine(lenghtLineCnt)).point2(1));
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
            if (max_y-min_y)>50 || (max_x-min_x)>50 || (double(max_y-min_y)/double(max_x-min_x))>20 || (double(max_x-min_x)/double(max_y-min_y))>20,  %��ͨ���г����ϳ���Ϊ�߿�Ӧȥ��,��������ϴ��Ҳ��ɾ��
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
            if wide>=5 || height>=5  %��ȥ��С����ͨ��
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