function [R, nt] = buildr(S, varargin)

%BUILDR Builds response matrix for input to functions ENTROPY and
% INFORMATION
%
%   ------
%   SYNTAX
%   ------
%
%       [R, nt] = build_R(S, R1, R2, ..., RL)
%
%   -----------
%   DESCRIPTION
%   -----------
%   Let's consider an experiment in which, during each trial, a stimulus is
%   presented out of NS available stimuli and L distinct neural responses
%   are recorded simultaneously. Within this framework the input to BUILDR
%   is as follow:
%   - S is the stimulus-array, i.e., S(i) stores the value of the stimulus
%     presented during the i-th trial.
%   - Rj, j=1,...,L, is the j-th response array, i.e., Rj(i) stores the
%     value of the j-th response recorded during the i-th experiment.
%
%   The function will return the response matrix R which can be input to
%   the routines ENTROPY and INFORMATION. The routine also outputs the
%   trials per stimulus array, NT, which can be used as one of the
%   parameters of the option structure for ENTROPY and INFORMATION.
%
%   -------
%   REMARKS
%   -------
%
%   - Although the one described above is the framework which was kept in
%     mind while creating the toolbox functions, it has to be noted that
%     this function (and also the other in the toolbox) can be easily
%     applied to several other situations.
%
%   - The goal of this function is to help the user get familiar with the
%     structure of the response-matrix R which is input to the ENTROPY and
%     INFORMATION functions and, in particular, with the fact that the
%     stimulus values are not provided to these functions. This is because,
%     for the sake of information computation the only important parameter
%     concerning the stimulus is the number of times each stimulus was
%     presented: the value of each stimulus can thus be mapped to an
%     integer value and made implicit as the index to a page of the
%     response matrix R. It needs to be noted, however, that BUILDR, having
%     to be as generic as possible, will also be relatively slow. Often,
%     the way responses are recorded or computed allows building a response
%     matrix much more quickly than the way done by BUILR. For
%     computationally intensive tasks it is thus suggested that custom
%     routines are used instead of this built-in tool.
%
%   See also ENTROPY, INFORMATION

%   Copyright (C) 2009 Cesare Magri
%   Version: 1.0.4

% -------
% LICENSE
% -------
% This software is distributed free under the condition that:
%
% 1. it shall not be incorporated in software that is subsequently sold;
%
% 2. the authorship of the software shall be acknowledged and the following
%    article shall be properly cited in any publication that uses results
%    generated by the software:
%
%      Magri C, Whittingstall K, Singh V, Logothetis NK, Panzeri S: A
%      toolbox for the fast information analysis of multiple-site LFP, EEG
%      and spike train recordings. BMC Neuroscience 2009 10(1):81;
%
% 3.  this notice shall remain in place in each source file.

if ~isvector(S)
    error('Stimulus array must be a 1-D array');
end

totNt = length(S);

L = length(varargin);

R1toL = zeros(L, totNt);
for k=1:L
    if ~isvector(varargin{k})
        msg = 'Response arrays must be 1-D.';
        error('buildr:respNot1D', msg);
    end
    
    if length(varargin{k}) ~= totNt
        msg = 'Each response-array must have the same length as the stimulus array';
        error('buildr:differentTotNt', msg);
    end
    
    R1toL(k,:) = varargin{k};
end

uniqueS = unique(S);
Ns = length(uniqueS);

% Dispalying informations:
disp('Building R and nt:');
disp(['- number of stimuli = ' num2str(Ns)]);
disp(['- number of responses = ' num2str(L)]);


nt = zeros(Ns,1);
tFlag = false(totNt, Ns);
for s=1:Ns
    tFlag(:,s) = S==uniqueS(s);
	nt(s) = sum(tFlag(:,s));
end

maxNt = max(nt);
disp(['- maximum numer of trials = ' num2str(maxNt)]);
disp(['- minimum numer of trials = ' num2str(min(nt))]);
R = zeros(L, maxNt, Ns);
for s=1:Ns
    if nt(s)>0
        R(:,1:nt(s), s) = R1toL(:, tFlag(:,s));
    else
        msg = 'One or more stimuli with no corresponding response.';
        error('buildr:noResponseStimulus', msg);
    end
end